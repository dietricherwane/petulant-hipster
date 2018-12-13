class AddSmsProviderIdToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :sms_provider_id, :integer
  end
end
