require 'rails_helper'

RSpec.describe 'Merchant bulk discounts new page' do
    before :each do
        @merchant1 = Merchant.create!(name: "Hair Care")

        @bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.3, quantity_threshold: 20, merchant_id: @merchant1.id)

        visit new_merchant_bulk_discount_path(@merchant1)
    end

    it 'shows a form to create a new bulk discount' do
        # Then I am taken to a new page where I see a form to add a new bulk discount
        # When I fill in the form with valid data
        # Then I am redirected back to the bulk discount index
        # And I see my new bulk discount listed
        
        fill_in "Percentage Discount", with: 0.4
        fill_in "Quantity Threshold", with: 30

        click_on "Create"
        expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
        
        expect("Percentage discount: 40.00%").to appear_before("Quantity Threshold: 30")
        expect(page).to have_content("Successfully Created!")
        
    end

    it 'displays flash notice if form not created properly' do
        
        fill_in "Percentage Discount", with: ""
        fill_in "Quantity Threshold", with: 30

        click_on "Create"
        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))

        expect(page).to have_content("Fill in all fields.")
    end
end