class AddSenderServiceToSmsTransactions < ActiveRecord::Migration
  def change
    add_column :sms_transactions, :sender_service, :string
  end
end
