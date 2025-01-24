# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransactionPolicy do
  subject(:transaction_policy) { described_class }

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:transaction) { create(:transaction, company: company) }

  permissions :index?, :new? do
    context 'when user has a current company' do
      before do
        create(:user_company, user:, company:)
        user.switch_current_company(company)
      end

      it 'grants access to index and new' do
        expect(transaction_policy).to permit(user, Transaction)
      end
    end

    context 'when user does not have a current company' do
      it 'denies access to index and new' do
        expect(transaction_policy).not_to permit(user, Transaction)
      end
    end
  end

  permissions :edit?, :create?, :update? do
    context "when the transaction is in the user's current company" do
      before do
        create(:user_company, user:, company:)
        user.switch_current_company(company)
      end

      it 'grants access to edit, create, and update' do
        expect(transaction_policy).to permit(user, transaction)
      end
    end

    context "when the transaction is not in the user's current company" do
      let(:random_transaction) { create(:transaction) }

      it 'denies access to edit, create, and update' do
        expect(transaction_policy).not_to permit(user, random_transaction)
      end
    end
  end

  permissions :destroy? do
    context "when the transaction is in the user's current company" do
      context 'when user is an admin for the company' do
        before do
          create(:user_company, user:, company:, role: 'admin')
          user.switch_current_company(company)
        end

        it 'grants access to destroy' do
          expect(transaction_policy).to permit(user, transaction)
        end
      end

      context 'when user is not an admin for the company' do
        it 'denies access to destroy' do
          expect(transaction_policy).not_to permit(user, transaction)
        end
      end
    end

    context "when the transaction is not in the user's current company" do
      let(:random_transaction) { create(:transaction) }

      it 'denies access to destroy' do
        expect(transaction_policy).not_to permit(user, random_transaction)
      end
    end
  end
end
