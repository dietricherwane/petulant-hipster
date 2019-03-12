class AddEmailFieldsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :email, :boolean
    add_column :profiles, :email_column, :integer
  end
end
