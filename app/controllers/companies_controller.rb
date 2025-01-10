class CompaniesController < ApplicationController
  before_action :set_company, only: %i[edit update destroy]
  def index
    @companies = current_user.companies
  end

  def new
    @company = Company.build
  end

  def create
    @company = Company.build(company_params)

    if @company.save
      @company.users << current_user
      redirect_to companies_path, notice: "#{@company.name} was successfully created"
      # respond_to do |format|
      #   format.html { redirect_to companies_path, notice: "#{@company.name} was successfully created" }
      #   format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully created" }
      # end
    else
      render :new, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def edit
  end

  def update
    if @company.update(company_params)
      redirect_to companies_path, notice: "#{@company.name} was successfully updated"
      # respond_to do |format|
      #   format.html { redirect_to companies_path, notice: "#{@company.name} was successfully updated" }
      #   format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully updated" }
      # end
    else
      render :edit, status: :unprocessable_entity, layout: 'modal'
    end
  end

  def destroy
    if @company.destroy
      redirect_to companies_path, notice: "#{@company.name} was successfully destroyed"
      # respond_to do |format|
      #   format.html { redirect_to companies_path, notice: "#{@company.name} was successfully destroyed" }
      #   format.turbo_stream { flash.now[:notice] = "#{@company.name} was successfully destroyed" }
      # end
    else
      redirect_to companies_path, notice: "#{@company.name} could not be destroyed"
    end
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def company_params
    params.require(:company).permit(:name)
  end
end
