# frozen_string_literal: true

class SubcategoriesController < ApplicationController
  before_action :set_subcategory, only: %i[edit update destroy]

  # GET /subcategories or /subcategories.json
  def index
    authorize Subcategory
    @subcategories = Subcategory.all
  end

  # GET /subcategories/new
  def new
    authorize Subcategory
    @subcategory = Subcategory.new
  end

  # GET /subcategories/1/edit
  def edit
    authorize @subcategory
  end

  # POST /subcategories or /subcategories.json
  def create
    @subcategory = Subcategory.new(subcategory_params)
    authorize @subcategory

    if @subcategory.save
      redirect_to subcategories_path, notice: "#{@subcategory.name} was successfully created."
    else
      render :new, status: :unprocessable_content
    end
    # respond_to do |format|
    #   if @subcategory.save
    #     format.html { redirect_to @subcategory, notice: 'Subcategory was successfully created.' }
    #     format.json { render :show, status: :created, location: @subcategory }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @subcategory.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /subcategories/1 or /subcategories/1.json
  def update
    authorize @subcategory

    if @subcategory.update(subcategory_params)
      redirect_to subcategories_path, notice: "#{@subcategory.name} was successfully updated."
    else
      render :edit, status: :unprocessable_content
    end
    # respond_to do |format|
    #   if @subcategory.update(subcategory_params)
    #     format.html { redirect_to @subcategory, notice: 'Subcategory was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @subcategory }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @subcategory.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /subcategories/1 or /subcategories/1.json
  def destroy
    authorize @subcategory

    @subcategory.destroy

    redirect_to subcategories_path, notice: 'Subcategory was successfully destroyed.'
    # respond_to do |format|
    #   format.html do
    #     redirect_to subcategories_path, status: :see_other, notice: 'Subcategory was successfully destroyed.'
    #   end
    #   format.json { head :no_content }
    # end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_subcategory
    @subcategory = Subcategory.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def subcategory_params
    params.expect(subcategory: %i[name category_id company_id])
  end
end
