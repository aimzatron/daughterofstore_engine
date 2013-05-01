require 'spec_helper'

describe ProductCategory do
  context "adding a category to a product that is from same store" do

    it "should be valid" do
      product = FactoryGirl.create(:product)
      category = FactoryGirl.create(:category, store: product.store)

      raise category.errors.inspect
      expect(category.errors).to be_empty
    end

  end
end
