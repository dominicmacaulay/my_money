# frozen_string_literal: true

class TransactionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  TRANSACTION_ATTRIBUTES = %i[date description amount transaction_type company_id categorizable].freeze

  # Multiplied from the start date rather than chained, so the 31st doesn't drift to the 28th for good.
  FREQUENCIES = {
    'daily' => { days: 1 },
    'weekly' => { weeks: 1 },
    'biweekly' => { weeks: 2 },
    'monthly' => { months: 1 },
    'quarterly' => { months: 3 },
    'yearly' => { years: 1 }
  }.freeze

  MAX_OCCURRENCES = 366

  SERIES_ATTRIBUTES = %w[amount_cents transaction_type categorizable_type categorizable_id].freeze

  attribute :recurring, :boolean, default: false
  attribute :end_date, :date
  attribute :frequency, :string
  attribute :occurrences, :string, default: 'this'

  attr_reader :transaction, :saved_count

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

  def recurring?
    recurring && transaction.new_record?
  end

  def save # rubocop:disable Naming/PredicateMethod
    return false unless valid?

    dates = occurrence_dates
    transaction.recurrence_id = SecureRandom.uuid if dates.many?

    ActiveRecord::Base.transaction do
      update_later_occurrences
      transaction.save!(validate: false)
      insert_later_occurrences(dates.drop(1))
    end
    @saved_count = dates.size
    true
  end

  private

  # Copies differ from the validated transaction only by date, so they skip validation.
  def insert_later_occurrences(later_dates)
    return if later_dates.empty?

    attributes = transaction.attributes.except('id', 'created_at', 'updated_at')
    Transaction.insert_all!(later_dates.map { |later_date| attributes.merge('date' => later_date) }) # rubocop:disable Rails/SkipsModelValidations
  end

  def update_later_occurrences
    later_occurrences.update_all(transaction.attributes.slice(*SERIES_ATTRIBUTES).merge(updated_at: Time.current)) # rubocop:disable Rails/SkipsModelValidations
  end

  def later_occurrences
    transaction.occurrences(occurrences).where.not(id: transaction.id)
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
