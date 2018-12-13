class AddEmailAndClearPasswordToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :email, :string
    add_column :customers, :clear_password, :string
  end
end
