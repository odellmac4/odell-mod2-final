FactoryBot.define do
  factory :create_bulk_discount do
    percentage_discount { 1.5 }
    quantity_threshold { 1 }
    merchant { nil }
  end

  factory :customer do
    first_name {Faker::Name.first_name}
    last_name {Faker::Dessert.variety}
  end

  factory :invoice do
    status {[0,1,2].sample}
    customer
  end

  factory :merchant do
    name {Faker::Space.galaxy}
    status { 1 }
  end

  factory :item do
    name {Faker::Coffee.variety}
    description {Faker::Hipster.sentence}
    unit_price {Faker::Number.decimal(l_digits: 2)}
    status { 0 }
    merchant
  end

  factory :transaction do
    result {[0,1].sample}
    credit_card_number {Faker::Finance.credit_card}
    invoice
  end

  factory :invoice_item do
    status {[0,1,2].sample}
    unit_price { 100 }
    quantity { 1 }
    item
    invoice
  end
end
