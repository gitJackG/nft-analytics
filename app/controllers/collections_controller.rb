class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show event ]

  def show
    @nfts = @collection.nfts.order(:token_id)

    if @nfts.empty?
      GetNftsFromCollectionJob.perform_async(@collection.slug_name)
      flash.now[:notice] = "No NFTs found for this collection yet. Fetching now..."
    end

    @results = ClickHouse.connection.select_all(
      "
      SELECT
        toDate(event_timestamp) AS day,
        countIf(event_type = 'sale') AS total_sales,
        sumIf(price, event_type = 'sale') AS total_volume,
        avgIf(price, event_type = 'sale') AS average_price,
        minIf(price, event_type = 'sale') AS floor_price,
        countIf(event_type = 'transfer') AS total_transfers,
        countIf(event_type = 'order') AS total_orders,
        uniqIf(taker, event_type = 'sale') AS unique_buyers,
        uniqIf(maker, event_type = 'sale') AS unique_sellers
      FROM collection_events
      WHERE collection_slug = '#{@collection.slug_name}'
      GROUP BY day
      ORDER BY day DESC
      ").to_a
  end

  def event
    GetCollectionEventDataJob.perform_async()
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_collection
    @collection = Collection.friendly.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def todo_params
    params.expect(collection: [ :slug_name ])
  end
end
