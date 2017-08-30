class AddSmsProviderTokenToParameters < ActiveRecord::Migration
  def change
    add_column :parameters, :sms_provider_token, :string
  end
end
