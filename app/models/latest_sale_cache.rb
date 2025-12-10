# app/models/latest_sale_cache.rb
class LatestSaleCache
  @latest_sale = nil
  class << self
    attr_accessor :latest_sale
  end
end
