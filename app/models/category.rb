# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :subcategories, dependent: :nullify
  has_many :transactions, as: :categorizable, dependent: :nullify
  has_many :subcategory_transactions, through: :subcategories, source: :transactions

  validates :name, presence: true
end
