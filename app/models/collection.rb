class Collection < ApplicationRecord
  extend FriendlyId
  friendly_id :slug_name, use: :slugged
  has_many :nfts
end
