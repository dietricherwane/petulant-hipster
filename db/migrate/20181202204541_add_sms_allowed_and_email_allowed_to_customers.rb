class AddSmsAllowedAndEmailAllowedToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :sms_allowed, :boolean
    add_column :customers, :email_allowed, :boolean
  end
end
