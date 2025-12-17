require "uri"
require "net/http"
require "json"

class GetCollectionEventDataJob
  include Sidekiq::Job

  sidekiq_options queue: :opensea, retry: 5

  def perform(slug)
    collection = Collection.friendly.find(slug)
    api_key    = Rails.application.credentials.opensea_api_key

    cutoff_time = [ collection.last_fetched_at, 1.hour.ago ].compact.max
    cutoff_ts   = cutoff_time.to_i

    next_cursor    = nil
    newest_seen_ts = cutoff_ts
    puts "Started #{slug}"
    page = 0
    loop do
      page += 1
      puts "Fetching page #{page} of #{slug}"
      uri = URI("https://api.opensea.io/api/v2/events/collection/#{slug}")
      params = {}
      params[:next] = next_cursor if next_cursor
      uri.query = URI.encode_www_form(params) if params.any?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 5
      http.read_timeout = 10

      request = Net::HTTP::Get.new(uri)
      request["accept"] = "*/*"
      request["x-api-key"] = api_key

      response = http.request(request)
      body     = JSON.parse(response.body)
      events   = body["asset_events"] || []

      break if events.empty?

      rows = []

      events.each do |e|
        ts = e["event_timestamp"].to_i
        break if ts < cutoff_ts

        newest_seen_ts = [ newest_seen_ts, ts ].max

        quantity_raw = e.dig("payment", "quantity") || "0"
        decimals     = e.dig("payment", "decimals") || 18
        price        = BigDecimal(quantity_raw) / (10 ** decimals)

        rows << {
          event_timestamp: Time.at(ts).utc.strftime("%Y-%m-%d %H:%M:%S"),
          event_type: e["event_type"],
          collection_slug: e.dig("criteria", "collection", "slug") || slug,
          contract_address: e.dig("criteria", "contract", "address") || "",
          token_id: e.dig("asset", "identifier") ||
                    e.dig("nft", "identifier") ||
                    "",
          price: price,
          payment_symbol: e.dig("payment", "symbol") || "",
          payment_token: e.dig("payment", "token_address") || "",
          maker: e["maker"] || e["from_address"] || e["buyer"] || "",
          taker: e["taker"] || e["to_address"] || e["seller"] || "",
          order_type: e["order_type"] || "",
          raw_quantity: e["quantity"] || 1
        }
      end

      ClickHouse.connection.insert("collection_events", rows) if rows.any?

      next_cursor = body["next"]
      break if next_cursor.blank?
      break if events.last["event_timestamp"].to_i < cutoff_ts
    end

    if newest_seen_ts > cutoff_ts
      collection.update_column(
        :last_fetched_at,
        Time.at(newest_seen_ts).utc
      )
    end
    Turbo::StreamsChannel.broadcast_refresh_to("collections")
    puts "Ended #{slug}"
  rescue => e
    Rails.logger.error("Failed fetching NFTs for #{slug}: #{e.message}")
    raise e
  end
end
