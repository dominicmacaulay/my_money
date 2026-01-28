# frozen_string_literal: true

class YearOverviewsController < ApplicationController
  def index
    authorize :year_overview

    @year_presenter = YearOverviewPresenter.new(current_company)
  end
end
