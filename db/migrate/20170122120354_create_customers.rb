class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :label
      t.string :uuid
      t.string :login
      t.string :password

      t.timestamps
    end
  end
end
