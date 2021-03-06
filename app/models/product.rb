class Product < ActiveRecord::Base
  attr_accessible :title, :description, :price,
                  :status, :category_ids, :image, :store_id

  belongs_to :store

  has_many :product_reviews
  has_many :ratings, through: :product_reviews
  has_many :questions, through: :ratings
  has_many :product_categories
  has_many :categories, through: :product_categories

  has_attached_file :image, styles: { retail: "500x500",
                                      large: "500x500",
                                      thumbnail: "200x200" }

  validates :title, presence: :true
  validate :unique_product_title_in_store
  validates :description, presence: :true
  validates :store_id, presence: :true
  validates :status, presence: :true,
                     inclusion: { in: %w(active retired) }
  validates :price, presence: :true,
                    format: { with: /^\d+??(?:\.\d{0,2})?$/ },
                    numericality: { greater_than: 0 }

  validate :same_store

  def same_store
    categories.each do |category|
      if category.store_id != store_id
        errors.add(:store_id, "product.store_id and category.store_id do not match")
      end
    end
  end

  scope :filter_by_category, lambda{ |category_id|
    joins(:categories).
    where("categories.id = ?", category_id) unless category_id.nil? }

  scope :order_by_average_rating, lambda{
    product_columns = columns.map { |c| "products.#{c.name}" }
    select_string = product_columns.join(", ")

    select("#{select_string}, avg(rating) as rating").
    joins(:ratings).group(select_string).order("rating DESC")
  }

  scope :order_by_rating, lambda{|question_id|
    product_columns = columns.map { |c| "products.#{c.name}" }
    select_string = product_columns.join(", ")

    select("#{select_string}, avg(rating) as rating").joins(:ratings).
    where("ratings.question_id = ?", question_id).
    group(select_string).order("rating DESC")
  }

  def unique_product_title_in_store
    if exists_in_store?(title, id, store_id)
      errors.add(:title,"This store can have only one product with this name")
    end
  end

  def exists_in_store?(title, id, store_id)
    if id && store_id
      !Store.find_by_id(store_id).products.where("title ILIKE ?", "%#{title}%").
                      where("id <> ?", id).empty?
    elsif store_id
      !Store.find_by_id(store_id).products.where("title ILIKE ?", "%#{title}%")
    else
      errors.add(:base, "Not valid without a store id")
    end
  end

  def toggle_status
    if status == 'active'
      update_attributes(status: 'retired')
    elsif status == 'retired'
      update_attributes(status: 'active')
    end
  end

  def active_product_reviews
    product_reviews.select {|product_review| product_review.status == 'active'}
  end

  def current_price
    price
  end

  def most_recent_reviews
    product_reviews.where(status: 'active').order("updated_at DESC")
  end

  def average_rating
    ratings.average(:rating) || 0
  end

  def average_ratings
    ratings = Hash.new(0)

    if !active_product_reviews.empty?
      active_product_reviews.each do |product_review|
        product_review.ratings.each do |rating|
          ratings[rating.question.question] += rating.rating
        end
      end

      ratings.each do |question, rating|
        ratings[question] = rating/active_product_reviews.count
      end
    end

    ratings
  end

  def featured_comment
    featured_comments.sample
  end

  def featured_comments
    product_reviews.where(featured: true)
  end

  def nonfeatured_comments
    product_reviews.where(featured: false)
  end

  def reviewers
    Customer.joins(:product_reviews).where("product_reviews.product_id = ?", id)
  end

  def reviewed_by? customer
    !Customer.joins(:product_reviews).
    where(
      "product_reviews.product_id = ? AND product_reviews.customer_id = ?",
       id,
       customer.id
       ).empty?
  end
end
