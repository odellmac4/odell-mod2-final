require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many(:bulk_discounts).through(:merchants) }
    it { should have_many :transactions}
  end
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end

    it '#discounted_revenue' do

      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Dog Shop')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Bone", description: "Bone", unit_price: 9, merchant_id: @merchant2.id)
      @item_9 = Item.create!(name: "Rope", description: "Rope", unit_price: 7, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-17 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_2.id, quantity: 9, unit_price: 9, status: 1)
      @ii_12 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_9.id, quantity: 12, unit_price: 7, status: 1)

      bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 8, merchant_id: @merchant1.id)
      bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.4, quantity_threshold: 10, merchant_id: @merchant2.id)
      bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 12, merchant_id: @merchant2.id)


      expect(@invoice_1.discounted_revenue).to eq(72)
      expect(@invoice_2.discounted_revenue).to eq(50.4)
    end

    it '#revenue_excluding_discounts' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Dog Shop')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Bone", description: "Bone", unit_price: 9, merchant_id: @merchant2.id)
      @item_9 = Item.create!(name: "Rope", description: "Rope", unit_price: 7, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-17 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_2.id, quantity: 9, unit_price: 9, status: 1)
      @ii_12 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_9.id, quantity: 12, unit_price: 7, status: 1)

      bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 8, merchant_id: @merchant1.id)
      bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.4, quantity_threshold: 10, merchant_id: @merchant2.id)
      bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 12, merchant_id: @merchant2.id)
      
      expect(@invoice_1.total_revenue).to eq(100)
      expect(@invoice_1.discounted_revenue).to eq(72)
      expect(@invoice_1.revenue_excluding_discounts).to eq(28)

      expect(@invoice_2.total_revenue).to eq(165)
      expect(@invoice_2.discounted_revenue).to eq(50.4)
      expect(@invoice_2.revenue_excluding_discounts).to eq(114.6)
    end
  end
end
