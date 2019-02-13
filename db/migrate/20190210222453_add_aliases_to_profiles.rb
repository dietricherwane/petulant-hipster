class AddAliasesToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :aliases, :text
  end
end
