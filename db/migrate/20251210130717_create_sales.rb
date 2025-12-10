class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.references :nft, null: false, foreign_key: true
      t.string :marketplace
      t.string :buyer_address
      t.string :seller_address
      t.string :taker
      t.decimal :price_eth
      t.integer :block_number
      t.string :transaction_hash
      t.datetime :timestamp

      t.timestamps
    end
  end
end
