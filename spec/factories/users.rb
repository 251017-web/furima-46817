FactoryBot.define do
  factory :user do
    nickname              { Faker::Name.initials(number: 2) }
    email                 { Faker::Internet.email }
    password              { "#{Faker::Internet.password(min_length: 6)}1a" } # Ensure both letter and number
    password_confirmation { password }
    last_name             { '山田' }
    first_name            { '陸太郎' }
    last_name_kana        { 'ヤマダ' }
    first_name_kana       { 'リクタロウ' }
    birthday              { Faker::Date.birthday(min_age: 18, max_age: 65) }
  end
end
