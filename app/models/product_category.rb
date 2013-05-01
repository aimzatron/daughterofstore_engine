class ProductCategory < ActiveRecord::Base
  attr_accessible :category_id, :product_id
  belongs_to :product
  belongs_to :category

  validates_uniqueness_of :product_id, scope: :category_id

	validate :same_store

	def same_store
    product.store_id == category.store_id
	end
end
