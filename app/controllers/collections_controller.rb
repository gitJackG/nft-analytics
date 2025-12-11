class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show event ]

  def show
    @nfts = @collection.nfts.order(:token_id)

    # if @nfts.empty?
    #   GetNftsFromCollectionJob.perform_async(@collection.slug_name)
    #   flash.now[:notice] = "No NFTs found for this collection yet. Fetching now..."
    # end

    sales_results = ClickHouse.connection.select_all("
      SELECT
        toStartOfHour(event_timestamp) AS hour,
        countIf(event_type = 'sale') AS total_sales,
        sumIf(price, event_type = 'sale') AS total_volume,
        avgIf(price, event_type = 'sale') AS average_price,
        minIf(price, event_type = 'sale') AS floor_price,
        uniqIf(taker, event_type = 'sale') AS unique_buyers,
        uniqIf(maker, event_type = 'sale') AS unique_sellers
      FROM collection_events
      WHERE collection_slug = '#{@collection.slug_name}' AND event_type = 'sale'
      GROUP BY hour
      ORDER BY hour DESC
    ").to_a

    orders_results = ClickHouse.connection.select_all("
      SELECT
        toStartOfHour(event_timestamp) AS hour,
        countIf(event_type = 'order') AS total_orders,
        countIf(order_type = 'item_offer') AS total_item_offers,       
        countIf(order_type = 'listing') AS total_listings,  
        countIf(order_type = 'trait_offer') AS total_trait_offers,  
        uniqIf(maker, event_type = 'order') AS unique_order_makers,
        uniqIf(taker, event_type = 'order') AS unique_order_takers, 
        argMax(maker, event_timestamp) AS latest_order_maker,
        MAX(event_timestamp) AS latest_order_timestamp
      FROM collection_events
      WHERE collection_slug = '#{@collection.slug_name}' AND event_type = 'order'
      GROUP BY hour
      ORDER BY hour DESC
    ").to_a

    transfers_results = ClickHouse.connection.select_all("
      SELECT
        toStartOfHour(event_timestamp) AS hour,
        countIf(event_type = 'transfer') AS total_transfers,
        uniq(maker) AS unique_transfer_senders,
        uniq(taker) AS unique_transfer_receivers,
        argMax(maker, event_timestamp) AS latest_transfer_sender,
        argMax(taker, event_timestamp) AS latest_transfer_receiver,
        MAX(event_timestamp) AS latest_transfer_timestamp
      FROM collection_events
      WHERE collection_slug = '#{@collection.slug_name}' AND event_type = 'transfer'
      GROUP BY hour
      ORDER BY hour DESC
    ").to_a

    @results = {
      sales_data: sales_results,
      orders_data: orders_results,
      transfers_data: transfers_results
    }
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
  def collection_params
    params.expect(collection: [ :slug_name ])
  end
end
