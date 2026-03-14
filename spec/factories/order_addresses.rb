FactoryBot.define do
  factory :order_address do
    post_code { "#{Faker::Number.number(digits: 3)}-#{Faker::Number.number(digits: 4)}" }
    prefecture_id { Faker::Number.between(from: 2, to: 48) }
    city { Faker::Address.city }
    block { Faker::Address.street_address }
    building { Faker::Address.secondary_address }
    phone_number { Faker::Number.leading_zero_number(digits: rand(10..11)) }
    token { "tok_#{Faker::Internet.password(min_length: 20, max_length: 30)}" }
  end
end
