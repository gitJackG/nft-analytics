class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show ]

  def show
    @nfts = @collection.nfts.order(:token_id)

    @results = ClickHouse.connection.select_all("
      SELECT
        toStartOfHour(event_timestamp) AS hour,
        countIf(event_type = 'sale') AS total_sales,
        countIf(event_type = 'order') AS total_orders,
        countIf(event_type = 'transfer') AS total_transfers,
        uniq(maker) AS unique_senders,
        uniq(taker) AS unique_receivers,
        argMax(maker, event_timestamp) AS latest_sender,
        argMax(taker, event_timestamp) AS latest_receiver,
        MAX(event_timestamp) AS latest_timestamp,
        MAX(price) AS highest_price,
        SUM(price) AS total_price
      FROM collection_events
      WHERE collection_slug = '#{@collection.slug_name}'
      GROUP BY hour
      ORDER BY hour DESC
    ").to_a

    metrics = {
      "Total Sales" => "total_sales",
      "Total Orders" => "total_orders",
      "Total Transfers" => "total_transfers"
    }

    reversed_results = @results.reverse

    @hourly_chart_data = metrics.map do |label, key|
      {
        name: label,
        data: reversed_results.map { |r| [ r["hour"], r[key] ]  }
      }
    end

    @hourly_chart_data << {
      name: "Total Events",
      data: reversed_results.map do |r|
        [
          r["hour"],
          r["total_sales"] + r["total_orders"] + r["total_transfers"]
        ]
      end
    }

    # @hourly_price_date = {
    #   name: "Total Price",
    #   data: reversed_results.map { |r| [ r["hour"], r["total_price"] ]  }
    # }
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
