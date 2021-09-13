FactoryBot.define do
  factory :post do
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    published { Faker::Boolean.boolean }
    user { create(:user) }
  end
end
