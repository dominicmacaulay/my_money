# frozen_string_literal: true

class YearOverviewPresenter
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def years
    current_year = Time.current.year
    transactions = company.transactions.order(:date)
    starting_year = transactions.first&.date&.year || current_year

    (starting_year..current_year).to_a
  end
end
