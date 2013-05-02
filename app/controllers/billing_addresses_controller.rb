class BillingAddressesController < ApplicationController
  before_filter :require_login
  before_filter :customer

  def new
    @billing_address = BillingAddress.new
  end

  def create
    billing_info = params[:billing_address]
    billing_info[:customer_id] = customer.id

    @billing_address = BillingAddress.new(billing_info)

    if @billing_address.save
      if session[:return_to] == profile_url
        redirect_to profile_path
      else
        customer.update_billing_address(@billing_address.id)
        redirect_to new_customer_credit_cards_path(customer)
      end
    else
      render "new"
    end
  end

  def edit
    current_customer_billing_address
  end

  def update
    if current_customer_billing_address.update_attributes(
                                      street_address: params[:street_address],
                                      city: params[:city],
                                      zip: params[:zip],
                                      state: params[:state]
                                      )
      redirect_to profile_path,
        :notice  => "Successfully updated billing address."
    else
      redirect_to profile_path, :notice  => "Update failed."
    end
  end

  def current_customer_billing_address
    @billing_address ||= BillingAddress.find_by_customer_id(customer.id)

  end

  def customer
    @customer ||= current_user ? current_user.customer : Customer.find_by_id(params[:customer_id])

  end
end
