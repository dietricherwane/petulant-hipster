class AddServiceIdToSmsTransactions < ActiveRecord::Migration
  def change
    add_column :sms_transactions, :service_id, :string
  end
end
