class CreateEmailTransactions < ActiveRecord::Migration
  def change
    create_table :email_transactions do |t|
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :profile_id
      t.text :description
      t.integer :send_messages
      t.integer :failed_messages
      t.integer :number_of_messages
      t.integer :user_id


      t.timestamps
    end
  end
end
