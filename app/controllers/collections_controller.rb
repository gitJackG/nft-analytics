class CollectionsController < ApplicationController
  before_action :set_collection, only: %i[ show ]

  def show
    @nfts = @collection.nfts.order(:identifier)

    if @nfts.empty?
      GetNftsFromCollectionJob.perform_async(@collection.slug_name)
      flash.now[:notice] = "No NFTs found for this collection yet. Fetching now..."
    end
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