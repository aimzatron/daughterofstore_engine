require File.dirname(__FILE__) + '/../spec_helper'

describe Category do

  before(:each) do
    @store = FactoryGirl.create(:store)
  end

  it 'has a valid factory' do
    category = FactoryGirl.build(:category, store_id: @store.id)
    expect(category).to be_valid
  end

  it 'is invalid without a title' do
    expect(FactoryGirl.build(:category, store_id: @store.id, title: '')).to_not be_valid
  end

  it 'is invalid if title already exists (case insensitive)' do
    cat1 = FactoryGirl.create(:category, title: 'dark MATTER', store_id: @store.id)
    expect(FactoryGirl.build(:category, title: 'dark matter', store_id: @store.id)).to_not be_valid
  end

  it 'is valid if another store has the same category, but not the same store' do
    cat1 = FactoryGirl.create(:category, store_id: @store.id)
    store2 = FactoryGirl.create(:store, name: 'my things', path: 'my-things')
    cat2 = FactoryGirl.build(:category, store_id: store2.id)

    expect(cat2).to be_valid
  end

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
