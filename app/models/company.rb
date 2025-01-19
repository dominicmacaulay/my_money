# frozen_string_literal: true

class Company < ApplicationRecord
  has_many :user_companies, dependent: :destroy
  has_many :users, through: :user_companies

  validates :name, presence: true

  def add_user_with_role(user, role = :guest)
    user_companies.create(user:, role:)
  end
end
