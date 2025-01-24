# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubcategoryPolicy do
  subject(:subcategory_policy) { described_class }

  let(:user) { create(:user) }
  let(:company) { create(:company) }
  let(:subcategory) { create(:subcategory, company: company) }

  permissions :index?, :new? do
    context 'when user has a current company' do
      before do
        create(:user_company, user:, company:)
        user.switch_current_company(company)
      end

      it 'grants access to index and new' do
        expect(subcategory_policy).to permit(user, Subcategory)
      end
    end

    context 'when user does not have a current company' do
      it 'denies access to index and new' do
        expect(subcategory_policy).not_to permit(user, Subcategory)
      end
    end
  end

  permissions :edit?, :create?, :update? do
    context "when the subcategory is in the user's current company" do
      before do
        create(:user_company, user:, company:)
        user.switch_current_company(company)
      end

      it 'grants access to edit, create, and update' do
        expect(subcategory_policy).to permit(user, subcategory)
      end
    end

    context "when the subcategory is not in the user's current company" do
      let(:random_subcategory) { create(:subcategory) }

      it 'denies access to edit, create, and update' do
        expect(subcategory_policy).not_to permit(user, random_subcategory)
      end
    end
  end

  permissions :destroy? do
    context "when the subcategory is in the user's current company" do
      context 'when user is an admin for the company' do
        before do
          create(:user_company, user:, company:, role: 'admin')
          user.switch_current_company(company)
        end

        it 'grants access to destroy' do
          expect(subcategory_policy).to permit(user, subcategory)
        end
      end

      context 'when user is not an admin for the company' do
        before do
          create(:user_company, user:, company:, role: 'member')
          user.switch_current_company(company)
        end

        it 'denies access to destroy' do
          expect(subcategory_policy).not_to permit(user, subcategory)
        end
      end
    end

    context "when the subcategory is not in the user's current company" do
      let(:random_subcategory) { create(:subcategory) }

      it 'denies access to destroy' do
        expect(subcategory_policy).not_to permit(user, random_subcategory)
      end
    end
  end
end
