# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :company
  belongs_to :categorizable, polymorphic: true, optional: true

  enum :transaction_type, { income: 'income', expense: 'expense' }, validate: true

  monetize :amount_cents, numericality: { greater_than: 0 }

  validates :date, :amount_cents, :transaction_type, presence: true

  validates :categorizable, absence: { message: 'cannot be present for income transactions' }, if: -> { income? }
  validates :categorizable, presence: { message: 'must be present for expense transactions' }, if: -> { expense? }

  paginates_per 25

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
end
