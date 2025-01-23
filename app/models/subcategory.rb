# frozen_string_literal: true

class Subcategory < ApplicationRecord
  belongs_to :category
  has_many :transactions, as: :categorizable, dependent: :destroy

  validates :name, presence: true

  delegate :name, to: :category, prefix: true
end
