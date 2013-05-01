require 'spec_helper'

describe BillingAddressesController do

  context 'new, edit, and update' do
    before(:each) do
      @customer = create(:customer)
      user = create(:user, customer: @customer)
      @billing_address = create(:billing_address, customer_id: @customer.id)
      controller.stub(:current_user).and_return(user)
    end

    describe 'GET #new' do
      it 'renders the new template' do
        get :new
        response.should render_template('new')
      end
    end

    describe 'GET #edit' do
      it 'assigns the customer' do
        get :edit
        assigns(:customer).should eq @customer
      end

      it 'assigns the associated billing address' do
        get :edit
        assigns(:billing_address).should eq @billing_address
      end
    end

    describe 'POST #update' do
      it 'assigns the customer' do
        post :update
        assigns(:customer).should eq @customer
      end
    end
  end

  describe 'POST #create' do
    before(:each) do
      @customer = create(:customer)
      user = create(:user, customer: @customer)
      controller.stub(:current_user).and_return(user)
    end

    it 'saves the billing address to the customer' do

      expect { post :create, {customer_id: @customer.id,
                    billing_address: {street_address: '231 Main St',
                                      city: 'Denver', zip: '12345',
                                      state: 'CO'}
                    }
      }.to change(BillingAddress, :count).by(1)
    end
  end
end
