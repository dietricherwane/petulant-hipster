class AddMd5PasswordToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :md5_password, :string
  end
end
