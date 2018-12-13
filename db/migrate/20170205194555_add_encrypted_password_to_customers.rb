class AddEncryptedPasswordToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :encrypted_password, :string
    add_column :customers, :iv, :string
    add_column :customers, :key, :string
  end
end
