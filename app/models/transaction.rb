# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :company
  belongs_to :categorizable, polymorphic: true, optional: true

  enum :transaction_type, { income: 'income', expense: 'expense' }, validate: true

  monetize :amount_cents, numericality: { greater_than: 0 }

  validates :date, :amount_cents, :transaction_type, presence: true

  validate :categorizable_presence_for_expense

  private

  def categorizable_presence_for_expense
    return unless expense? && categorizable.nil?

    errors.add(:categorizable, 'must be present for expense transactions')
  end
end
