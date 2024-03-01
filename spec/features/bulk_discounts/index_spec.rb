require 'rails_helper'

RSpec.describe 'Merchant bulk discounts index page' do
    
    before :each do
        @merchant1 = Merchant.create!(name: "Hair Care")

        @bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.3, quantity_threshold: 20, merchant_id: @merchant1.id)

        visit merchant_bulk_discounts_path(@merchant1)
    end

    it 'shows link to each bulk discount show page along with their attributes' do
        # Where I see all of my bulk discounts including their
        # percentage discount and quantity thresholds
        # And each bulk discount listed includes a link to its show page
        within("#bulk_discount-#{@bulk_discount1.id}") do
            expect(page).to have_link("Bulk Discount: #{@bulk_discount1.id}")
            expect(page).to have_content("Percentage discount: 20.00%")
            expect(page).to have_content("Quantity Threshold: 10")

            click_link "Bulk Discount: #{@bulk_discount1.id}"
            expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @bulk_discount1))
        end

        visit merchant_bulk_discounts_path(@merchant1)

        within("#bulk_discount-#{@bulk_discount2.id}") do
            expect(page).to have_link("Bulk Discount: #{@bulk_discount2.id}")
            expect(page).to have_content("Percentage discount: 30.00%")
            expect(page).to have_content("Quantity Threshold: 20")

            click_link "Bulk Discount: #{@bulk_discount2.id}"
            expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @bulk_discount2))
        end
    end

    it 'displays a button to create a new discount' do
        # When I visit my bulk discounts index
        # Then I see a link to create a new discount
        expect(page).to have_link("Create New Discount")
        # When I click this link
        click_link "Create New Discount"
        # Then I am taken to a new page where I see a form to add a new bulk discount
        expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
    end
end