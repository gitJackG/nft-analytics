require "uri"
require "net/http"
require "json"

class GetCollectionEventDataJob
  include Sidekiq::Job

  def perform(collection_slug)
    collection = Collection.friendly.find(collection_slug)
    opensea_api_key = Rails.application.credentials.opensea_api_key

    url = URI("https://api.opensea.io/api/v2/events/collection/#{collection_slug}?limit=1")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["accept"] = "*/*"
    request["x-api-key"] = opensea_api_key

    response = http.request(request)
    puts response.read_body

    # Update last refresh time
    Rails.cache.write("last_refreshed", Time.now.utc)

  rescue => e
    Rails.logger.error("Failed fetching NFTs for #{collection_slug}: #{e.message}")
    raise e
  end
end
