class AddCollectionRefToNfts < ActiveRecord::Migration[8.1]
  def change
    add_reference :nfts, :collection, null: false, foreign_key: true
  end
end
