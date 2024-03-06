class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item
  has_many :bulk_discounts, through: :item

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def max_discount_percentage
    bulk_discount = self.discount_applied
    if bulk_discount
      percentage_discount = bulk_discount.percentage_discount
    end
  end

  def self.discounted_revenue
    total_discounted_revenue = 0

    all.each do |invoice_item|

      max_discount_percentage = invoice_item.max_discount_percentage

      if max_discount_percentage.present?
        discounted_price = invoice_item.unit_price * (1 - max_discount_percentage)
        total_discounted_revenue += discounted_price * invoice_item.quantity
      end
    end
    total_discounted_revenue
  end

  def discount_applied
      bulk_discounts.where("#{self.quantity} >= bulk_discounts.quantity_threshold").order(percentage_discount: :desc).first
  end
end
