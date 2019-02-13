class AddUserIdAndCustomerIdToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :user_id, :integer
    add_column :profiles, :customer_id, :integer
  end
end
