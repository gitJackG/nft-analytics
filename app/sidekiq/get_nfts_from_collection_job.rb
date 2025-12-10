require 'uri'
require 'net/http'
require 'json'

class GetNftsFromCollectionJob
  include Sidekiq::Job

  def perform(collection_slug)
    collection = Collection.friendly.find(collection_slug)
    opensea_api_key = Rails.application.credentials.opensea_api_key

    url = URI("https://api.opensea.io/api/v2/collection/#{collection_slug}/nfts")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["accept"] = '*/*'
    request["x-api-key"] = opensea_api_key

    response = http.request(request)

    # Only proceed if successful
    return unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    nfts = data["nfts"] || []  # depending on API response key
    nfts.each do |nft_data|
      Nft.find_or_initialize_by(collection_id: collection.id, identifier: nft_data["identifier"]).tap do |nft|
        nft.assign_attributes(
          name:                  nft_data["name"],
          description:           nft_data["description"],
          image_url:             nft_data["image_url"],
          display_image_url:     nft_data["display_image_url"],
          display_animation_url: nft_data["display_animation_url"],
          metadata_url:          nft_data["metadata_url"],
          opensea_url:           nft_data["opensea_url"],
          contract:              nft_data["contract"],
          token_standard:        nft_data["token_standard"],
          updated_at_api:        nft_data["updated_at"],
          is_disabled:           nft_data["is_disabled"],
          is_nsfw:               nft_data["is_nsfw"]
        )
        nft.save!
      end
    end

    # Update last refresh time
    Rails.cache.write("last_refreshed", Time.now.utc)

  rescue => e
    Rails.logger.error("Failed fetching NFTs for #{collection_slug}: #{e.message}")
    raise e
  end
end
