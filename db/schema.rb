# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_10_160449) do
  create_table "collections", force: :cascade do |t|
    t.string "banner_image_url"
    t.string "category"
    t.string "contract_address"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "image_url"
    t.string "name"
    t.string "opensea_url"
    t.string "owner"
    t.string "slug"
    t.string "slug_name", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_collections_on_slug", unique: true
    t.index ["slug_name"], name: "index_collections_on_slug_name", unique: true
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "nfts", force: :cascade do |t|
    t.string "collection"
    t.integer "collection_id", null: false
    t.string "contract"
    t.datetime "created_at", null: false
    t.text "description"
    t.string "display_animation_url"
    t.string "display_image_url"
    t.string "image_url"
    t.boolean "is_disabled", default: false
    t.boolean "is_nsfw", default: false
    t.string "metadata_url"
    t.string "name"
    t.string "opensea_url"
    t.string "token_id", null: false
    t.string "token_standard"
    t.datetime "updated_at", null: false
    t.datetime "updated_at_api"
    t.index ["collection", "token_id"], name: "index_nfts_on_collection_and_token_id", unique: true
    t.index ["collection_id"], name: "index_nfts_on_collection_id"
  end

  create_table "sales", force: :cascade do |t|
    t.integer "block_number"
    t.string "buyer_address"
    t.datetime "created_at", null: false
    t.string "marketplace"
    t.integer "nft_id", null: false
    t.decimal "price_eth"
    t.string "seller_address"
    t.string "taker"
    t.datetime "timestamp"
    t.string "transaction_hash"
    t.datetime "updated_at", null: false
    t.index ["nft_id"], name: "index_sales_on_nft_id"
  end

  add_foreign_key "nfts", "collections"
  add_foreign_key "sales", "nfts"
end
