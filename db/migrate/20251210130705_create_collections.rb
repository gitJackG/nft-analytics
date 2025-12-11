class CreateCollections < ActiveRecord::Migration[8.1]
  def change
    create_table :collections do |t|
      t.string :slug_name, null: false
      t.string :name
      t.text   :description
      t.string :image_url
      t.string :banner_image_url
      t.string :owner
      t.string :category
      t.string :opensea_url
      t.string :contract_address
      t.timestamps
    end

    add_index :collections, :slug_name, unique: true
  end
end
