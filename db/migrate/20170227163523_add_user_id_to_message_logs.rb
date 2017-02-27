class AddUserIdToMessageLogs < ActiveRecord::Migration
  def change
    add_column :message_logs, :user_id, :integer
  end
end
