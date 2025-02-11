# frozen_string_literal: true

class Subcategory < ApplicationRecord
  belongs_to :category
  belongs_to :company

  has_many :transactions, as: :categorizable, dependent: :nullify

  validates :name, presence: true

  delegate :name, to: :category, prefix: true
end
