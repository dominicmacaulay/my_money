# frozen_string_literal: true

class CompaniesController < ApplicationController
  before_action :set_company, only: %i[edit update destroy set_current]
  def index
    @companies = authorize current_user.companies
  end

  def new
    @company = authorize Company.build
  end

  def edit; end

  def create
    @company = authorize Company.build(company_params)

    if @company.save
      @company.users << current_user
      current_user.switch_current_company(@company)

      # redirect_to companies_path, notice: "#{@company.name} was successfully created"
      respond_to do |format|
        format.html { redirect_to companies_path, notice: "#{@company.name} was successfully created" }
        format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully created" }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: "#{@company.name} was successfully updated"
      # respond_to do |format|
      #   format.html { redirect_to companies_path, notice: "#{@company.name} was successfully updated" }
      #   format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully updated" }
      # end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @company.destroy

    redirect_to companies_path, notice: "#{@company.name} was successfully destroyed"
    # respond_to do |format|
    #   format.html { redirect_to companies_path, notice: "#{@company.name} was successfully destroyed" }
    #   format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully destroyed" }
    # end
  end

  def set_current
    if current_user.switch_current_company(@company)
      redirect_to root_path, notice: "Current company set to #{@company.name}"
    else
      redirect_to companies_path, alert: 'Could not set current company'
    end
  end

  private

  def set_company
    @company = authorize Company.find(params[:id])
  end

  def company_params
    params.expect(company: [:name])
  end
end
