# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_company

  def index
    year = params[:year].presence&.to_i || Date.current.year
    @report = Report.new(@company, year)
  end

  private

  def set_company
    @company = authorize current_company
  end
end
