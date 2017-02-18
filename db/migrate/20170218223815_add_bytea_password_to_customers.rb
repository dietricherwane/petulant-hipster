class AddByteaPasswordToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bytea_password, :bytea
  end
end
