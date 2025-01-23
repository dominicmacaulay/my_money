# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :company
  belongs_to :categorizable, polymorphic: true, optional: true

  enum :transaction_type, { income: 'income', expense: 'expense' }, validate: true

  monetize :amount_cents, numericality: { greater_than: 0 }

  validates :date, :amount_cents, :transaction_type, presence: true

  validate :categorizable_presence_for_expense

  def categorizable=(categorizable)
    if categorizable.is_a?(String) # Check if it is a signed global id
      super(GlobalID::Locator.locate_signed(categorizable))
    else
      super
    end
  end

  def categorizable_name
    categorizable&.name
  end

  private

  def categorizable_presence_for_expense
    return unless expense? && categorizable.nil?

    errors.add(:categorizable, 'must be present for expense transactions')
  end
end
