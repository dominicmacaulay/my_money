# frozen_string_literal: true

class UserCompany < ApplicationRecord
  belongs_to :user
  belongs_to :company

  enum :role, { admin: 'admin', member: 'member' }, validate: true
end
