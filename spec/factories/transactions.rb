FactoryBot.define do
  factory :transaction do
    date { Date.today }
    sequence(:description) { |n| "Transaction ##{n}" }
    amount { 100.00 }
    company { create(:company) }
    transaction_type { 0 }

    trait :income do
      transaction_type { 0 }
    end

    trait :expense do
      transaction_type { 1 }
    end
  end
end
