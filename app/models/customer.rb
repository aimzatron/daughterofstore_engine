class Customer < ActiveRecord::Base
  attr_accessible :email, :full_name, :user

  has_one :user
  has_one :billing_address
  has_one :shipping_address
  has_one :credit_card
  has_many :orders
  has_many :product_reviews

  validates :full_name, presence: :true
  validates :email, presence: :true, uniqueness: { case_sensitive: false },
            format: { with: /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/ }

  accepts_nested_attributes_for :user

  def best_display_name
    #if customer has a user AND a display name, use it.
    if user && user.display_name
      user.display_name
    else #otherwise, generate a random display name to use from a set
      use_customer_initials
    end
  end

  def use_customer_initials
    full_name.split.collect {|w| w[0]}.join('.') + '.'
  end

  def has_purchased_product? product_id
    orders.joins(:order_items).
           where("order_items.product_id = ?", product_id).count > 0
  end

  def update_billing_address(billing_address_id)
    self.billing_address_id = billing_address_id
    save
  end

  def update_shipping_address(shipping_address_id)
    self.shipping_address_id = shipping_address_id
  end

  def update_credit_card(credit_card_id)
    self.credit_card_id = credit_card_id
    save
  end
end
