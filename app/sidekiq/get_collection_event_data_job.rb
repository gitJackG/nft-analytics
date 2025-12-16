require "uri"
require "net/http"
require "json"

class GetCollectionEventDataJob
  include Sidekiq::Job

  sidekiq_options queue: :opensea, retry: 5

  def perform(slug)
    opensea_api_key = Rails.application.credentials.opensea_api_key

    url = URI("https://api.opensea.io/api/v2/events/collection/#{slug}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Get.new(url)
    request["accept"] = "*/*"
    request["x-api-key"] = opensea_api_key

    response = http.request(request)
    body = JSON.parse(response.body)
    events = body["asset_events"] || []

    rows = []
    puts slug
    events.each do |e|
      ts = Time.at(e["event_timestamp"]).utc.strftime("%Y-%m-%d %H:%M:%S")

      quantity_raw = e.dig("payment", "quantity") || "0"
      decimals     = e.dig("payment", "decimals") || 18
      price        = BigDecimal(quantity_raw) / (10 ** decimals)

      rows << {
        event_timestamp: ts,
        event_type: e["event_type"],
        collection_slug: e.dig("criteria", "collection", "slug") || slug,
        contract_address: e.dig("criteria", "contract", "address") || "",
        token_id: e.dig("asset", "identifier") || e.dig("nft", "identifier") || "",
        price: price,
        payment_symbol: e.dig("payment", "symbol") || "",
        payment_token: e.dig("payment", "token_address") || "",
        maker: e["maker"] || e["from_address"] || e["buyer"] || "",
        taker: e["taker"] || e["to_address"] || e["seller"] || "",
        order_type: e["order_type"] || "",
        raw_quantity: e["quantity"] || 1
      }
    end
    puts "Ended #{slug}"
    Turbo::StreamsChannel.broadcast_refresh_to("collections")
    Rails.cache.write("last_refreshed", Time.now.utc)
    ClickHouse.connection.insert("collection_events", rows) if rows.any?
  rescue => e
    Rails.logger.error("Failed fetching NFTs for #{slug}: #{e.message}")
    raise e
  end
end
