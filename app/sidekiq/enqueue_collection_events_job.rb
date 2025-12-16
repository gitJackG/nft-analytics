class EnqueueCollectionEventsJob
  include Sidekiq::Job

  sidekiq_options queue: :default, retry: false

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
  ].freeze

  def perform
    TOP_SLUGS.each do |slug|
      GetCollectionEventDataJob.perform_async(slug)
    end

    Rails.cache.write("last_refreshed", Time.now.utc)
  end
end
