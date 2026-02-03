# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_company

  def show
    @year = params[:year].to_i
  end

  private

  def set_company
    @company = authorize Company.find(params[:company_id])
  end
end
