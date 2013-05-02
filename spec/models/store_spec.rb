require 'spec_helper'

describe Store do
  it 'has a valid factory' do
    expect(FactoryGirl.build(:store)).to be_valid
  end

  it 'is not valid without a name' do
    store = FactoryGirl.build(:store, name: '')
    expect(store.valid?).to be_false
  end

  it 'is not valid without a path' do
    store = FactoryGirl.build(:store, path: '')
    expect(store.valid?).to be_false
  end

  it 'is not valid without a description' do
    store = FactoryGirl.build(:store, description: '')
    expect(store.valid?).to be_false
  end

  context 'given a previous store with same info was declined' do
    it 'can be valid' do
    declined_store = FactoryGirl.create(:store, approval_status: 'declined')
    expect(FactoryGirl.build(:store).valid?).to be_true
    end
  end

  describe '#filter_products_by_category' do
    context 'a category exists' do
      it "should return an array of products that have that category" do
      store = FactoryGirl.build(:store, name:"store", path:"storepath")
      category1 = store.categories.build(title: "category 1")
      category2 = store.categories.build(title: "category 2")
      store.save!

      product1 = FactoryGirl.create(:product, title: "p1", store_id: store.id)
      product1.categories << category1

      product2 = FactoryGirl.create(:product, title: "p2", store_id: store.id)
      product2.categories << category1
      product2.categories << category2

      categories = store.filter_products_by_category(category2.id)
      expect(categories).to eq [product2]
      end
    end

  end

  describe "#top_products" do

    it "sorts the top rated products based on average rating for a given store" do
      store = create(:store)

      product1 = create(:product, store: store)
      product2 = create(:product, store: store)
      product3 = create(:product, store: store)
      product4 = create(:product, store: store)
      product5 = create(:product, store: store)

      prod_review1 = create(:product_review, product_id: product1.id)
      prod_review2 = create(:product_review, product_id: product2.id)
      prod_review3 = create(:product_review, product_id: product3.id)
      prod_review4 = create(:product_review, product_id: product4.id)
      prod_review5 = create(:product_review, product_id: product5.id)

      rating1 = create(:rating, product_review: prod_review1, rating: 5)
      rating2 = create(:rating, product_review: prod_review2, rating: 4)
      rating3 = create(:rating, product_review: prod_review3, rating: 3)
      rating4 = create(:rating, product_review: prod_review4, rating: 2)
      rating5 = create(:rating, product_review: prod_review5, rating: 1)

      expect(store.top_products).to eq [product1, product2, product3, product4]
    end
  end

  describe "search" do

    context "a sorted_by value exists" do
      let(:store) {FactoryGirl.create(:store)}
      let(:p1) {FactoryGirl.create(:product, store: store)}
      let(:p2) {FactoryGirl.create(:product, store: store)}
      let(:p3) {FactoryGirl.create(:product, store: store)}

      let(:question1) { FactoryGirl.create(:durability_question)}
      let(:question2) { FactoryGirl.create(:packaging_question)}
      let(:question3) { FactoryGirl.create(:question)}

      before do
        customers = [
          FactoryGirl.create(:customer),
          FactoryGirl.create(:customer),
          FactoryGirl.create(:customer)
        ]

        p4 = FactoryGirl.create(:product)

        create_ratings(p1, 1, [question1, question2, question3], customers)
        create_ratings(p2, 3, [question1, question2, question3], customers)
        create_ratings(p3, 5, [question1, question2], customers)
        create_ratings(p4, 3, [question1, question2, question3], customers)

      end

      it "returns the products sorted by the average rating from highest to lowest" do
        products = store.search(sorted_by: "average_rating")
        expect(products).to eq [p1, p2, p3].sort_by { |p| -p.average_rating }
      end

       it "returns the products sorted by the rating of a question from highest to lowest" do
         products = store.search(sorted_by: question3.id)
         expect(products).to eq [p2, p1]
       end

      it "returns filtered products sorted by the rating of a question from highest to lowest within a category" do
        category = FactoryGirl.create(:category, store: store)
        category.products << [p1, p2]

        products = store.search(category_id: category.id, sorted_by: question1.id)
        expect(products).to eq [p2, p1]
      end
    end
  end

  describe "inactive" do
    context "if the store is pending" do
      it "is now inactive" do
        store = FactoryGirl.create(:store, approval_status: "pending", active: true)
        expect(store).to_not be_inactive
      end
    end
    context "if the store is not pending and is active" do
      it "is not inactive" do
        store = FactoryGirl.create(:store, approval_status: "approved", active: true)
        expect(store).to_not be_inactive
      end
    end

    context "if the store is not active" do
      it "is inactive" do
        store = FactoryGirl.create(:store, approval_status: "approved", active: false)
        expect(store).to be_inactive
      end
    end

  end

  describe "questions" do
    it "returns a list of questions associated with any products of the store" do
        store = FactoryGirl.create(:store)
        product1 = FactoryGirl.create(:search_product, store: store)
        questions = product1.ratings.collect(&:question)

        FactoryGirl.create(:question)

        expect(store.questions).to match_array(questions)
    end
  end

end

def create_ratings p1, rating, questions, customers

  customers.each do |customer1|
    p = FactoryGirl.create(:product_review, customer: customer1, product: p1)

    questions.each do |question1|
      p.ratings.create(question_id: question1.id, rating: rating)
    end
  end

end

