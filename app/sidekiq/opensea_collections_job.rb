require "uri"
require "net/http"
require "json"

class OpenseaCollectionsJob
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
    opensea_api_key = Rails.application.credentials.opensea_api_key

    TOP_SLUGS.each do |slug|
      url = URI("https://api.opensea.io/api/v2/collections/#{slug}")

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request["accept"] = "*/*"
      request["x-api-key"] = opensea_api_key

      response = http.request(request)
      next unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)
      Collection.find_or_initialize_by(slug_name: slug).tap do |col|
        col.name            = data["name"]
        col.description     = data["description"]
        col.image_url       = data["image_url"]
        col.banner_image_url= data["banner_image_url"]
        col.owner           = data["owner"]
        col.category        = data["category"]
        col.opensea_url     = data["opensea_url"]
        col.contract_address= data["contracts"]&.first&.[]("address")
        col.save!
      end
    end

    Rails.cache.write("last_refreshed", Time.now.utc)
  rescue => e
    Rails.logger.error("Failed fetching top collections: #{e.message}")
    raise e
  end
end
