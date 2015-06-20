class CreateCustomLogs < ActiveRecord::Migration
  def change
    create_table :custom_logs do |t|
      t.text :sender_service
      t.text :message
      t.text :msisdn

      t.timestamps
    end
  end
end
