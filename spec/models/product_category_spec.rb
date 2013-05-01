require 'spec_helper'

describe ProductCategory do
  context "adding a category to a product that is from same store" do

    it "should be valid" do
      product = FactoryGirl.create(:product)
      category = FactoryGirl.create(:category, store: product.store)
      category.products << product
      category.save

      expect(category).to be_valid
    end

  end

  context "adding a category to a product that is not from the same store" do
    it "should not be valid" do
      store = FactoryGirl.create(:store)
      product = FactoryGirl.create(:product)
      category = FactoryGirl.create(:category, store: store)

      category.products << product
      category.save

      expect(category).to_not be_valid
    end

  end
end
