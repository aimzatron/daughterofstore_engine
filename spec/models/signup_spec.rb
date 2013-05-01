require 'spec_helper'

describe Signup do
  describe 'initialize' do
    context 'the customer already exists' do
      before(:each) do
        @customer = create(:customer, email: 'myemail@email.com')
      end

      context 'the user already exists, too' do
        before(:each) do
          user = create(:user, customer: @customer)
          @params = {email: 'myemail@email.com', full_name: 'Daniel Boone',
                password: 'password', password_confirmation: 'password', display_name:'Booner'}
        end

        it 'creates a new signup' do
          signup = Signup.new(@params)
          expect(signup).to be_kind_of Signup
        end

        it 'does not add any new users or customers' do
          pre_count = User.all.count
          pre_customer_count = Customer.all.count
          signup = Signup.new(@params)
          expect(pre_count).to eq User.all.count
          expect(pre_customer_count).to eq Customer.all.count
        end
      end
    end
  end
end
