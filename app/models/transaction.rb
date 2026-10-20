# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :company
  belongs_to :categorizable, polymorphic: true, optional: true

  enum :transaction_type, { income: 'income', expense: 'expense' }, validate: true

  monetize :amount_cents, numericality: { greater_than: 0 }

  validates :date, :amount_cents, :transaction_type, presence: true

  validates :categorizable, absence: { message: 'cannot be present for income transactions' }, if: -> { income? }
  validates :categorizable, presence: { message: 'must be present for expense transactions' }, if: -> { expense? }

  delegate :name, to: :categorizable, prefix: true, allow_nil: true

  paginates_per 25

  def recurring?
    recurrence_id.present?
  end

  # Includes this transaction. Uses the stored date so pending edits to it don't move the cutoff.
  def this_and_future_occurrences
    return self.class.where(id:) unless recurring?

    self.class.where(company_id:, recurrence_id:).where(date: date_in_database..)
  end

  def categorizable=(categorizable)
    if categorizable.is_a?(String) # Check if it is a signed global id
      super(GlobalID::Locator.locate_signed(categorizable))
    else
      super
    end
  end
end
