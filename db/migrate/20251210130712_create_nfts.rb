class CreateNfts < ActiveRecord::Migration[8.1]
  def change
    create_table :nfts do |t|
      t.string   :identifier, null: false
      t.string   :collection
      t.string   :contract
      t.string   :token_standard
      t.string   :name
      t.text     :description
      t.string   :image_url
      t.string   :display_image_url
      t.string   :display_animation_url
      t.string   :metadata_url
      t.string   :opensea_url
      t.datetime :updated_at_api
      t.boolean  :is_disabled, default: false
      t.boolean  :is_nsfw, default: false

      t.timestamps
    end

    add_index :nfts, [:collection, :identifier], unique: true
  end
end