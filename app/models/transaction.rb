class Transaction < ApplicationRecord
  belongs_to :company

  enum :transaction_type, [ :income, :expense ]

  validates :date, :amount, :transaction_type, presence: true
  validates :amount, numericality: true
  validate :amount_has_two_decimal_places

  private

  def amount_has_two_decimal_places
    if amount.present? && amount.to_s.split(".").last.size > 2
      errors.add(:amount, "must have at most two decimal places")
    end
  end
end
