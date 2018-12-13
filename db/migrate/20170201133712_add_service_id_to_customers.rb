class AddServiceIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :service_id, :string
  end
end
