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

    it 'can edit a bulk discount' do
        # As a merchant
        # When I visit my bulk discount show page
        # Then I see a link to edit the bulk discount
        expect(page).to have_link("Edit Bulk Discount")
        # When I click this link
        click_link "Edit Bulk Discount"
        # Then I am taken to a new page with a form to edit the discount
        expect(current_path).to eq edit_merchant_bulk_discount_path(@merchant1, @bulk_discount2)
        # And I see that the discounts current attributes are pre-poluated in the form
        expect(page).to have_field("Percentage Discount", with: "0.3")
        expect(page).to have_field("Quantity Threshold", with: "20")
        # When I change any/all of the information and click submit
        fill_in "Percentage Discount", with: "0.65"
        fill_in "Quantity Threshold", with: "35"

        click_button "Submit"
        # Then I am redirected to the bulk discount's show page
        expect(current_path).to eq merchant_bulk_discount_path(@merchant1, @bulk_discount2)
        # And I see that the discount's attributes have been updated
        expect(page).to have_content("Percentage discount: 65.00%")
        expect(page).to have_content("Quantity threshold: 35")
    end

end