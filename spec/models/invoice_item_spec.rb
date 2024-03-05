require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
    it { should have_many(:bulk_discounts).through(:item) }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @m2 = Merchant.create!(name: 'Merchant 2')
      @m3 = Merchant.create!(name: 'Merchant 3')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @item_4 = Item.create!(name: 'Bone', description: 'Cheese-filled', unit_price: 8, merchant_id: @m2.id)
      @item_5 = Item.create!(name: 'Rope', description: 'Tug o war', unit_price: 9, merchant_id: @m2.id)
      @item_6 = Item.create!(name: 'Treats', description: 'PB treats', unit_price: 7, merchant_id: @m2.id)
      @item_7 = Item.create!(name: 'Treats', description: 'PB treats', unit_price: 7, merchant_id: @m3.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 11, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 12, unit_price: 5, status: 1)
      @ii_5 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_4.id, quantity: 6, unit_price: 8, status: 1)
      @ii_6 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_5.id, quantity: 8, unit_price: 9, status: 1)
      @ii_7 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_6.id, quantity: 10, unit_price: 7, status: 1)
      @ii_8 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_1.id, quantity: 10, unit_price: 7, status: 1)

      @bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 10, merchant_id: @m1.id)
      @bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 8, merchant_id: @m2.id)
      @bulk_discount3 = BulkDiscount.create!(percentage_discount: 0.5, quantity_threshold: 12, merchant_id: @m2.id)
      @bulk_discount4 = BulkDiscount.create!(percentage_discount: 0.75, quantity_threshold: 10, merchant_id: @m2.id)
    end
    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to match_array([@i1, @i3])
    end

    it '#discount_eligible' do
      expect(InvoiceItem.discount_eligible).to match_array([@ii_2, @ii_4, @ii_6, @ii_7, @ii_8])

      expect(@i1.invoice_items.discount_eligible).to match_array([@ii_2, @ii_6, @ii_7])
      expect(@i2.invoice_items.discount_eligible).to match_array([@ii_8])
    end

    it '#max_discount_percentage' do
      expect(InvoiceItem.max_discount_percentage).to eq(0.75)
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


      expect(@invoice_1.invoice_items.discounted_revenue).to eq(72)
      expect(@invoice_2.invoice_items).to eq([@ii_2, @ii_12])
      expect(@invoice_2.invoice_items.discount_eligible).to eq([@ii_12])
      expect(@invoice_2.invoice_items.discounted_revenue).to eq(50.4)
    end
  end

  describe 'insance methods' do
    before(:each) do
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

      @bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 8, merchant_id: @merchant1.id)
      @bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.25, quantity_threshold: 9, merchant_id: @merchant1.id)
      @bulk_discount3 = BulkDiscount.create!(percentage_discount: 0.4, quantity_threshold: 10, merchant_id: @merchant2.id)
      @bulk_discount4 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 12, merchant_id: @merchant2.id)
      @bulk_discount5 = BulkDiscount.create!(percentage_discount: 0.1, quantity_threshold: 7, merchant_id: @merchant1.id)
    end

    it 'retrieves the discount applied to the invoice_item' do
      expect(@invoice_2.invoice_items.discount_eligible).to eq([@ii_12])
      expect(@ii_12.bulk_discounts).to match_array([@bulk_discount3, @bulk_discount4])
      expect(@ii_12.discount_applied).to eq(@bulk_discount3)

      expect(@ii_1.bulk_discounts).to match_array([@bulk_discount1, @bulk_discount2, @bulk_discount5])
      expect(@ii_1.discount_applied).to eq(@bulk_discount2)
    end
  end
end
