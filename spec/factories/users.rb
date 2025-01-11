FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:first_name) { |n| "user#{n}" }
    last_name { 'test' }
    password { 'password' }
  end
end
