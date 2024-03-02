class BulkDiscountsController < ApplicationController
    def index
        @merchant = Merchant.find(params[:merchant_id])
        @bulk_discounts = @merchant.bulk_discounts
    end

    def show
        @bulk_discount = BulkDiscount.find(params[:id])
        @merchant = Merchant.find(params[:merchant_id])
    end

    def new
        @merchant = Merchant.find(params[:merchant_id])
        @bulk_discount = BulkDiscount.new
    end

    def create
        merchant = Merchant.find(params[:merchant_id])
        @bulk_discount = BulkDiscount.create!(bulk_discount_params)
        redirect_to (merchant_bulk_discounts_path(merchant))
    end

    def destroy
        BulkDiscount.destroy(params[:id])
        redirect_to (merchant_bulk_discounts_path(params[:merchant_id]))
    end

    def edit
        @bulk_discount = BulkDiscount.find(params[:id])
        @merchant = Merchant.find(params[:merchant_id])
    end

    def update
        merchant = Merchant.find(params[:merchant_id])
        bulk_discount = BulkDiscount.find(params[:id])
        if bulk_discount.update(bulk_discount_params)
          redirect_to merchant_bulk_discount_path(merchant, bulk_discount)
        end
    end

    private

    def bulk_discount_params
        if params[:action] == 'create'
            params.require(:bulk_discount).permit(:percentage_discount, :quantity_threshold).merge(merchant_id: params[:merchant_id])
        else
            params.require(:bulk_discount).permit(:percentage_discount, :quantity_threshold)
        end
    end
end