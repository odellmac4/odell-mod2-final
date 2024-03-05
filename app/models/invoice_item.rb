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

  def self.discount_eligible
    self.joins(:bulk_discounts).where("quantity >= bulk_discounts.quantity_threshold").distinct
  end

  def self.max_discount_percentage
    self.joins(:bulk_discounts).maximum(:percentage_discount)
  end

  def self.discounted_revenue
    if max_discount_percentage.present?
      total_discounted_revenue = self.discount_eligible
      .sum("invoice_items.unit_price * invoice_items.quantity * (1 - #{self.max_discount_percentage})")
    else
      total_discounted_revenue = 0
    end
  end

  def discount_applied
      bulk_discounts.where("#{self.quantity} >= bulk_discounts.quantity_threshold").order(percentage_discount: :desc).first
  end
end
