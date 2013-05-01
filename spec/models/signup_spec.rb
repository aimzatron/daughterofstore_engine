require 'spec_helper'

describe Signup do
  describe 'initialize' do
    context 'the customer already exists' do
      before(:each) do
        @customer = create(:customer)
      end
      it 'creates a user with the existing customer info' do
        pending
      end

      context 'the user already exists, too' do
        it 'does not create a new customer or user' do
        user = create(:user, customer: @customer)
        expect()
        end
      end
    end

    context 'the customer is new' do
      pending
    end
  end
end
