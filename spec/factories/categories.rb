# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category ##{n}" }

    trait :has_subcategory do
      after(:create) do |category|
        create(:subcategory, category:)
      end
    end
  end
end
