# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_companies, dependent: :destroy
  has_many :companies, through: :user_companies

  def admin_for_company?(company)
    user_companies.find_by(company:)&.admin?
  end
end
