class CreateEmailLogs < ActiveRecord::Migration
  def change
    create_table :email_logs do |t|
      t.integer :subscriber_id
      t.string :email
      t.integer :profile_id
      t.text :message
      t.string :status

      t.timestamps
    end
  end
end
