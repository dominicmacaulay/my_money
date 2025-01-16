# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    date { Time.zone.today }
    sequence(:description) { |n| "Transaction ##{n}" }
    amount { 100.00 }
    company { create(:company) }
    transaction_type { 'income' }

    trait :income do
      transaction_type { 'income' }
    end

    trait :expense do
      transaction_type { 'expense' }
    end
  end
end
