# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_company

  def index
    @report = Report.new(@company, params[:year].to_i)
  end

  private

  def set_company
    @company = authorize current_company
  end
end
