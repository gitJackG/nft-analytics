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
    puts "Page Refresh"
    Rails.cache.write("last_refreshed", Time.now.utc)
    TOP_SLUGS.each do |slug|
      GetCollectionEventDataJob.perform_async(slug)
    end
  end
end
