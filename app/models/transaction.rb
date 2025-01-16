# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :company

  enum :transaction_type, { income: 'income', expense: 'expense' }, validate: true

  monetize :amount_cents

  validates :date, :amount_cents, :transaction_type, presence: true
end
