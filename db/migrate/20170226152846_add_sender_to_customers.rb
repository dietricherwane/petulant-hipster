class AddSenderToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :sender, :string
  end
end
