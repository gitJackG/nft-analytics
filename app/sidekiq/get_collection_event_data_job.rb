require "uri"
require "net/http"
require "json"

class GetCollectionEventDataJob
  include Sidekiq::Job

    TOP_SLUGS = [
    "cryptopunks",
    "boredapeyachtclub",
    "mutant-ape-yacht-club",
    "azuki",
    "pudgypenguins",
    "otherdeed",
    "clonex",
    "moonbirds",
    "doodles-official",
    "wrapped-cryptopunks",
    "bored-ape-kennel-club",
    "meebits"
  ]

  def perform
    renderer = ApplicationController.renderer.new
    current_slug = nil
    TOP_SLUGS.each do |slug|
      current_slug = slug
      collection = Collection.friendly.find(slug)
      opensea_api_key = Rails.application.credentials.opensea_api_key

      url = URI("https://api.opensea.io/api/v2/events/collection/#{slug}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["accept"] = "*/*"
      request["x-api-key"] = opensea_api_key

      response = http.request(request)
      puts slug

      body = JSON.parse(response.body)
      events = body["asset_events"] || []

      client = ClickHouse.connection

      rows = []

      events.each do |e|
        ts = Time.at(e["event_timestamp"]).utc.strftime("%Y-%m-%d %H:%M:%S")
        event_type = e["event_type"]

        collection_slug  = e.dig("criteria", "collection", "slug") || slug
        contract_address = e.dig("criteria", "contract", "address") || ""

        quantity_raw = e.dig("payment", "quantity") || "0"
        decimals     = e.dig("payment", "decimals") || 18
        payment_symbol = e.dig("payment", "symbol") || ""
        payment_token  = e.dig("payment", "token_address") || ""

        price = quantity_raw.to_f / (10**decimals)

        token_id = e.dig("asset", "identifier") ||
                  e.dig("nft", "identifier") ||
                  ""

        maker = e["maker"] || ""
        taker = e["taker"] || ""
        from_address = e["from_address"] || ""
        to_address   = e["to_address"] || ""

        trait_type  = e.dig("criteria", "trait", "type") || ""
        trait_value = e.dig("criteria", "trait", "value") || ""

        order_type  = e["order_type"] || ""
        raw_quantity = e["quantity"] || 1

        rows << {
          event_timestamp: ts,
          event_type: event_type,
          collection_slug: collection_slug,
          contract_address: contract_address,
          token_id: token_id,
          price: price,
          payment_symbol: payment_symbol,
          payment_token: payment_token,
          maker: maker,
          taker: taker,
          from_address: from_address,
          to_address: to_address,
          order_type: order_type,
          trait_type: trait_type,
          trait_value: trait_value,
          raw_quantity: raw_quantity
        }
      end
      client.insert("collection_events", rows)
    end
    Turbo::StreamsChannel.broadcast_refresh_to("collections")
    Rails.cache.write("last_refreshed", Time.now.utc)

  rescue => e
    Rails.logger.error("Failed fetching NFTs for #{current_slug}: #{e.message}")
    raise e
  end
end
