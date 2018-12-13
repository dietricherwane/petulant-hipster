class AddBulkEmailToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :bulk_email, :integer
  end
end
