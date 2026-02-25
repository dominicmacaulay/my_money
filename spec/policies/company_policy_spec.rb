# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanyPolicy do
  subject(:company_policy) { described_class }

  let(:user) { create(:user) }
  let(:company) { create(:company) }

  permissions :index?, :new?, :create? do
    it 'grants access to index, set_current, new, and create' do
      expect(company_policy).to permit(user, company)
    end
  end

  permissions :set_current?, :show? do
    context 'when user belongs to the company' do
      before do
        create(:user_company, user:, company:)
      end

      it 'grants access to set_current and show' do
        expect(company_policy).to permit(user, company)
      end
    end

    context 'when user does not belong to the company' do
      it 'denies access to set_current and show' do
        expect(company_policy).not_to permit(user, company)
      end
    end
  end

  permissions :edit?, :update?, :destroy? do
    context 'when user is an admin for the company' do
      before do
        create(:user_company, user:, company:, role: 'admin')
      end

      it 'grants access to edit, update, and destroy' do
        expect(company_policy).to permit(user, company)
      end
    end

    context 'when user is not an admin for the company' do
      it 'denies access to edit, update, and destroy' do
        expect(company_policy).not_to permit(user, company)
      end
    end
  end
end
