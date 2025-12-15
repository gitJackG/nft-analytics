class AddLastFetchedAtToCollections < ActiveRecord::Migration[8.1]
  def change
    add_column :collections, :last_fetched_at, :datetime
  end
end
