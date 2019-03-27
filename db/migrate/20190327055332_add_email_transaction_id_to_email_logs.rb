class AddEmailTransactionIdToEmailLogs < ActiveRecord::Migration
  def change
    add_column :email_logs, :email_transaction_id, :integer
    add_column :email_logs, :subject, :string
    add_column :email_logs, :sender, :string
  end
end
