# frozen_string_literal: true

class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[edit update destroy]

  # GET /transactions or /transactions.json
  def index
    authorize Transaction

    @transactions = current_company.transactions.order(date: :desc)
    @total_income = @transactions.income.sum(:amount_cents) / 100
    @total_expense = @transactions.expense.sum(:amount_cents) / 100
  end

  # GET /transactions/new
  def new
    authorize Transaction
    @transaction = Transaction.new
    @transaction.transaction_type = params[:transaction_type]
  end

  # GET /transactions/1/edit
  def edit
    authorize @transaction
  end

  # POST /transactions or /transactions.json
  def create # rubocop:disable Metrics/MethodLength
    @transaction = Transaction.new(transaction_params)
    authorize @transaction

    if @transaction.save
      if params[:submit_and_new] == 'true'
        redirect_to new_transaction_path(transaction_type: @transaction.transaction_type),
                    notice: 'Transaction was successfully created. Please create another.'
      else
        redirect_to transactions_path, notice: 'Transaction was successfully created.'
      end
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
  def update # rubocop:disable Metrics/MethodLength
    authorize @transaction

    if @transaction.update(transaction_params)
      if params[:submit_and_new] == 'true'
        redirect_to new_transaction_path(transaction_type: @transaction.transaction_type),
                    notice: 'Transaction was successfully updated. Please create another.'
      else
        redirect_to transactions_path, notice: 'Transaction was successfully updated.'
      end
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
    authorize @transaction

    @transaction.destroy

    redirect_to transactions_path, notice: 'Transaction was successfully destroyed.'
    # respond_to do |format|
    #   format.html { redirect_to transactions_path, status: :see_other, notice: "Transaction was successfully destroyed." } # rubocop:disable Layout/LineLength
    #   format.json { head :no_content }
    # end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction = Transaction.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def transaction_params
    params.expect(transaction: %i[date description amount transaction_type company_id
                                        categorizable])
  end
end
