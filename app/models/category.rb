# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :subcategories, dependent: :nullify
  has_many :transactions, as: :categorizable, dependent: :nullify

  validates :name, presence: true
end
