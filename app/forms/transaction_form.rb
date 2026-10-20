# frozen_string_literal: true

class TransactionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  TRANSACTION_ATTRIBUTES = %i[date description amount transaction_type company_id categorizable].freeze

  # Steps are multiplied from the start date rather than chained, so a monthly series starting on
  # the 31st lands on the last day of shorter months without drifting earlier for the rest of the series.
  FREQUENCIES = {
    'daily' => { days: 1 },
    'weekly' => { weeks: 1 },
    'biweekly' => { weeks: 2 },
    'monthly' => { months: 1 },
    'quarterly' => { months: 3 },
    'yearly' => { years: 1 }
  }.freeze

  MAX_OCCURRENCES = 366

  attribute :recurring, :boolean, default: false
  attribute :end_date, :date
  attribute :frequency, :string

  attr_reader :transaction

  delegate(*TRANSACTION_ATTRIBUTES, *TRANSACTION_ATTRIBUTES.map { |attr| :"#{attr}=" }, to: :transaction)
  delegate :id, :persisted?, :to_key, :to_param, :column_for_attribute, :has_attribute?, to: :transaction

  validate :transaction_valid
  validates :frequency, inclusion: { in: FREQUENCIES.keys }, if: :recurring?
  validates :end_date, presence: true, if: :recurring?
  validate :end_date_valid, if: :recurring?

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Transaction')
  end

  def initialize(attributes = {}, transaction: Transaction.new)
    @transaction = transaction
    @new_transaction = transaction.new_record?
    super(attributes)
  end

  # Only new transactions can recur; editing one never fans out into a series.
  def recurring?
    recurring && @new_transaction
  end

  def save # rubocop:disable Naming/PredicateMethod
    return false unless valid?

    ActiveRecord::Base.transaction { transactions.each(&:save!) }
    true
  end

  # The first occurrence is the wrapped transaction itself; the rest are copies differing only by date.
  def transactions
    occurrence_dates.map.with_index do |occurrence_date, index|
      next transaction if index.zero?

      transaction.dup.tap { |copy| copy.date = occurrence_date }
    end
  end

  private

  def occurrence_dates
    return [date] unless recurring?

    step = FREQUENCIES.fetch(frequency)

    (0..).lazy
         .map { |index| date.advance(step.transform_values { |value| value * index }) }
         .take_while { |occurrence_date| occurrence_date <= end_date }
         .first(MAX_OCCURRENCES + 1)
  end

  def transaction_valid
    return if transaction.valid?

    errors.merge!(transaction.errors)
  end

  def end_date_valid
    return if [date, end_date, frequency].any?(&:blank?) || errors.include?(:frequency)

    if end_date <= date
      errors.add(:end_date, 'must be after the transaction date')
    elsif occurrence_dates.size > MAX_OCCURRENCES
      errors.add(:end_date, "would create more than #{MAX_OCCURRENCES} transactions")
    end
  end
end
