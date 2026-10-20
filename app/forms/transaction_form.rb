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
  # When editing a recurring transaction, whether changes apply to just it or it and every later occurrence.
  attribute :occurrences, :string, default: 'this'

  # The saved occurrences, set by #save. The first is the wrapped transaction; the rest are copies differing by date.
  attr_reader :transaction, :transactions

  delegate(*TRANSACTION_ATTRIBUTES, *TRANSACTION_ATTRIBUTES.map { |attr| :"#{attr}=" }, to: :transaction)
  delegate :id, :persisted?, :column_for_attribute, :has_attribute?, to: :transaction

  validate :transaction_valid
  validates :frequency, inclusion: { in: FREQUENCIES.keys }, if: :recurring?
  validates :end_date, presence: true, if: :recurring?
  validate :end_date_valid, if: :recurring?
  validates :occurrences, inclusion: { in: Transaction::OCCURRENCE_SCOPES }

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Transaction')
  end

  def initialize(transaction = Transaction.new, attributes = {})
    @transaction = transaction
    super(attributes)
  end

  # Only new transactions can recur; editing one never fans out into a series.
  def recurring?
    recurring && transaction.new_record?
  end

  def save # rubocop:disable Naming/PredicateMethod
    return false unless valid?

    ActiveRecord::Base.transaction do
      update_later_occurrences
      @transactions = build_transactions.each(&:save!)
    end
    true
  end

  private

  def build_transactions
    transaction.recurrence_id = SecureRandom.uuid if recurring?

    occurrence_dates.map.with_index do |occurrence_date, index|
      next transaction if index.zero?

      transaction.dup.tap { |copy| copy.date = occurrence_date }
    end
  end

  # Later occurrences take the same edits; a date change shifts each of them by the same number of days.
  def update_later_occurrences
    changes = transaction.changes_to_save.except('date').transform_values(&:last)

    later_occurrences.find_each do |occurrence|
      occurrence.update!(changes.merge(date: occurrence.date + date_shift))
    end
  end

  def later_occurrences
    transaction.occurrences(occurrences).where.not(id: transaction.id)
  end

  def date_shift
    transaction.date - transaction.date_in_database
  end

  def occurrence_dates
    return [date] unless recurring?

    step = FREQUENCIES.fetch(frequency)

    (0..MAX_OCCURRENCES).lazy
                        .map { |index| date.advance(step.transform_values { |value| value * index }) }
                        .take_while { |occurrence_date| occurrence_date <= end_date }
                        .to_a
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
