class DashboardController < ApplicationController
  def main
    @last_refreshed = Rails.cache.read("last_refreshed")
    @collections    = Collection.all

    if @collections.empty?
      OpenseaCollectionsJob.perform_async
      flash.now[:notice] = "No collections found yet. Fetching now..."
    end
  end
end