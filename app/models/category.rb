class Category < ActiveRecord::Base
  attr_accessible :title, :product_ids, :store_id

  has_many :product_categories
  has_many :products, through: :product_categories
  belongs_to :store

  validates_uniqueness_of :title, scope: :store_id, :case_sensitive => false
  validates :title, presence: true

  validate :same_store

  def same_store
    products.each do |product|
      if product.store_id != store_id
        errors.add(:store_id, "product.store_id and category.store_id do not match")
      end
    end
  end
end
