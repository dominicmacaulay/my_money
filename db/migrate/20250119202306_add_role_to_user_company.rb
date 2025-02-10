class AddRoleToUserCompany < ActiveRecord::Migration[8.0]
  def up
    add_column :user_companies, :role, :string, default: 'admin'

    UserCompany.find_each do |user_company|
      if user_company.company.users.count == 1
        user_company.update(role: 'admin')
      else
        user_company.update(role: 'member')
      end
    end

    change_column_null :user_companies, :role, false
  end

  def down
    remove_column :user_companies, :role
  end
end
