class AddBulkToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bulk, :integer
  end
end
