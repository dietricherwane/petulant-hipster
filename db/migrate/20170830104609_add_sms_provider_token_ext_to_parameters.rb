class AddSmsProviderTokenExtToParameters < ActiveRecord::Migration
  def change
    add_column :parameters, :sms_provider_token_ext, :text
  end
end
