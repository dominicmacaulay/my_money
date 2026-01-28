# frozen_string_literal: true

class YearOverviewPresenter
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def years
    current_year = Time.current.year
    starting_year = company.transactions.minimum(:date)&.year || current_year

    (starting_year..current_year).to_a.reverse
  end
end
