class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.where(company_id: current_company.id)
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
  end

  # GET /transactions/1/edit
  def edit
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      redirect_to transactions_path, notice: "Transaction was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
    # respond_to do |format|
    #   if @transaction.save
    #     format.html { redirect_to @transaction, notice: "Transaction was successfully created." }
    #     format.json { render :show, status: :created, location: @transaction }
    #   else
    #     format.html { render :new, status: :unprocessable_entity }
    #     format.json { render json: @transaction.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
    # respond_to do |format|
    #   if @transaction.update(transaction_params)
    #     format.html { redirect_to @transaction, notice: "Transaction was successfully updated." }
    #     format.json { render :show, status: :ok, location: @transaction }
    #   else
    #     format.html { render :edit, status: :unprocessable_entity }
    #     format.json { render json: @transaction.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    if @transaction.destroy

      redirect_to transactions_path, notice: "Transaction was successfully destroyed."
    # respond_to do |format|
    #   format.html { redirect_to transactions_path, status: :see_other, notice: "Transaction was successfully destroyed." }
    #   format.json { head :no_content }
    # end
    else
      redirect_to transactions_path, notice: "Transaction could not be destroyed."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params.require(:transaction).permit(:date, :description, :amount, :transaction_type, :company_id)
    end
end
