# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[edit update destroy set_current]
  def index
    authorize Company
    @companies = current_user.companies
  end

  def new
    authorize Company
    @company = Company.build
  end

  def edit
    authorize @company
  end

  def create
    @company = Company.build(company_params)
    authorize @company

    if @company.save
      @company.users << current_user
      set_current_company_id(@company.id)

      redirect_to companies_path, notice: "#{@company.name} was successfully created"
    else
      render :new, status: :unprocessable_content, layout: 'modal'
    end
  end

  def update
    authorize @company

    if @company.update(company_params)
      redirect_to companies_path, notice: "#{@company.name} was successfully updated"
    else
      render :edit, status: :unprocessable_content, layout: 'modal'
    end
  end

  def destroy
    authorize @company

    @company.destroy

    redirect_to companies_path, notice: "#{@company.name} was successfully destroyed"
  end

  def set_current
    authorize @company

    set_current_company_id(@company.id)
    redirect_to root_path, notice: "Current company set to #{@company.name}"
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.expect(company: [:name])
  end
end
