# frozen_string_literal: true

class TransactionsController < ApplicationController
  DEFAULT_TRANSACTION_GROUPING = :all
  TRANSACTION_GROUPING_OPTIONS = %i[all income expense].freeze

  before_action :set_transaction, only: %i[edit update destroy]

  # GET /transactions or /transactions.json
  def index
    authorize Transaction

    set_session_transaction_grouping

    @transactions_presenter = TransactionsPresenter.new(current_company, session_transaction_grouping)
    @transactions = @transactions_presenter.transactions.page(params[:page])
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
      render :new, status: :unprocessable_content
    end
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
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    authorize @transaction

    @transaction.destroy

    redirect_to transactions_path, notice: 'Transaction was successfully destroyed.'
  end

  private

  def session_transaction_grouping
    session[:transaction_grouping]&.to_sym || DEFAULT_TRANSACTION_GROUPING
  end

  def set_session_transaction_grouping
    new_grouping = params[:transaction_grouping]&.to_sym
    return unless TRANSACTION_GROUPING_OPTIONS.include?(new_grouping)

    session[:transaction_grouping] = new_grouping
  end

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
