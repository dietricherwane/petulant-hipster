class AddCustomerIdToEmailTransactions < ActiveRecord::Migration
  def change
    add_column :email_transactions, :customer_id, :integer
  end
end
