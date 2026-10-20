# frozen_string_literal: true

class TransactionsController < ApplicationController
  DEFAULT_TRANSACTION_GROUPING = :all
  DEFAULT_TRANSACTION_YEAR = Time.current.year
  TRANSACTION_GROUPING_OPTIONS = %i[all income expense].freeze

  before_action :set_transaction, only: %i[edit update destroy]
  before_action :set_transaction_form, only: %i[edit update]

  # GET /transactions or /transactions.json
  def index
    authorize Transaction

    set_session_transaction_grouping
    set_session_transaction_year_and_years

    @transactions_presenter = TransactionsPresenter.new(
      current_company,
      session_transaction_grouping,
      session_transaction_year
    )
    @transactions = @transactions_presenter.transactions.page(params[:page])
  end

  # GET /transactions/new
  def new
    authorize Transaction
    @transaction_form = TransactionForm.new({ transaction_type: params[:transaction_type], date: params[:date] })
  end

  # GET /transactions/recurrence
  def recurrence
    authorize Transaction, :new?
    render partial: 'recurrence', locals: { transaction_form: TransactionForm.new({ recurring: params[:recurring] }) }
  end

  # GET /transactions/1/edit
  def edit
    authorize @transaction
  end

  # POST /transactions or /transactions.json
  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @transaction_form = TransactionForm.new(transaction_params)
    authorize @transaction_form.transaction

    if @transaction_form.save
      notice = success_notice(@transaction_form.transactions.size, 'created')
      if params[:submit_and_new] == 'true'
        redirect_to new_transaction_path(transaction_type: @transaction_form.transaction_type,
                                         date: @transaction_form.date),
                    notice: "#{notice} Please create another."
      else
        redirect_to transactions_path, notice:
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    authorize @transaction

    @transaction_form.assign_attributes(transaction_params)

    if @transaction_form.save
      redirect_to transactions_path, notice: 'Transaction was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    authorize @transaction

    destroyed = if params[:occurrences] == 'future'
                  @transaction.this_and_future_occurrences.destroy_all
                else
                  [@transaction.destroy]
                end

    redirect_to transactions_path, notice: success_notice(destroyed.size, 'destroyed')
  end

  private

  def session_transaction_grouping
    session[:transaction_grouping]&.to_sym || DEFAULT_TRANSACTION_GROUPING
  end

  def session_transaction_year
    session[:transaction_year] || DEFAULT_TRANSACTION_YEAR
  end

  def set_session_transaction_grouping
    new_grouping = params[:transaction_grouping]&.to_sym
    return unless TRANSACTION_GROUPING_OPTIONS.include?(new_grouping)

    session[:transaction_grouping] = new_grouping
  end

  def set_session_transaction_year_and_years
    @transaction_years = YearOverviewPresenter.new(current_company).years

    new_year = params[:transaction_year]&.to_i
    return unless @transaction_years.include?(new_year)

    session[:transaction_year] = new_year
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_transaction
    @transaction = Transaction.find(params.expect(:id))
  end

  def success_notice(count, action)
    count == 1 ? "Transaction was successfully #{action}." : "#{count} transactions were successfully #{action}."
  end

  def set_transaction_form
    @transaction_form = TransactionForm.new(transaction: @transaction)
  end

  # Only allow a list of trusted parameters through.
  def transaction_params
    params.expect(transaction: %i[date description amount transaction_type company_id
                                  categorizable recurring end_date frequency occurrences])
  end
end
