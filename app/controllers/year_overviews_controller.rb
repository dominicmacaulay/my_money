# frozen_string_literal: true

class YearOverviewsController < ApplicationController
  def index
    authorize :year_overview

    @year_presenter = YearOverviewPresenter.new(current_company)
  end

  def show
    authorize :year_overview

    @report = Report.new(current_company, params[:id].to_i)
  end
end
