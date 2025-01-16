# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "company#{n}" }
  end
end
