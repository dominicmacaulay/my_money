# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :subcategories, dependent: :destroy
  has_many :transactions, as: :categorizable, dependent: :destroy

  validates :name, presence: true
end
