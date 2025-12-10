class Nft < ApplicationRecord
  belongs_to :collection
  has_many :sales
end
