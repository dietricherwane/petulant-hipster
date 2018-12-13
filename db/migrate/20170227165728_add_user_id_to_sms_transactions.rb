class AddUserIdToSmsTransactions < ActiveRecord::Migration
  def change
    add_column :sms_transactions, :user_id, :integer
  end
end
