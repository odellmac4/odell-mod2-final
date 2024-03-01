require 'rails_helper'

RSpec.describe 'Merchant bulk discounts show page' do
    before :each do
        @merchant1 = Merchant.create!(name: "Hair Care")

        @bulk_discount1 = BulkDiscount.create!(percentage_discount: 0.2, quantity_threshold: 10, merchant_id: @merchant1.id)
        @bulk_discount2 = BulkDiscount.create!(percentage_discount: 0.3, quantity_threshold: 20, merchant_id: @merchant1.id)

        visit merchant_bulk_discount_path(@merchant1, @bulk_discount2)
    end

    it 'displays the bulk discount attributes' do
        # As a merchant
        # When I visit my bulk discount show page
        # Then I see the bulk discount's quantity threshold and percentage discount
        expect(page).to have_content("Bulk Discount - #{@bulk_discount2.id}")
        expect(page).to have_content("Percentage discount: 30.00%")
        expect(page).to have_content("Quantity threshold: 20")
    end

end