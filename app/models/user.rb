class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :user_companies, dependent: :destroy
  has_many :companies, through: :user_companies
  belongs_to :current_company, class_name: "Company", optional: true


  def set_current_company(company)
    return unless companies.include?(company)

    update!(current_company: company)
  end
end
