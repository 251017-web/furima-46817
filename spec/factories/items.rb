FactoryBot.define do
  factory :item do
    name             { Faker::Commerce.product_name }
    description      { Faker::Lorem.sentence }
    category_id      { Faker::Number.between(from: 2, to: 11) }
    condition_id     { Faker::Number.between(from: 2, to: 7) }
    delivery_fee_id  { Faker::Number.between(from: 2, to: 3) }
    prefecture_id    { Faker::Number.between(from: 2, to: 48) }
    shipping_date_id { Faker::Number.between(from: 2, to: 4) }
    price            { Faker::Number.between(from: 300, to: 9_999_999) }
    association :user

    after(:build) do |item|
      item.image.attach(io: StringIO.new('dummy_image'), filename: 'test_image.png', content_type: 'image/png')
    end
  end
end
