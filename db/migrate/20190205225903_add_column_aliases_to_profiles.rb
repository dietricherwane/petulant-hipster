class AddColumnAliasesToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :col1a, :string
    add_column :profiles, :col2a, :string
    add_column :profiles, :col3a, :string
    add_column :profiles, :col4a, :string
    add_column :profiles, :col5a, :string
    add_column :profiles, :col6a, :string
    add_column :profiles, :col7a, :string
    add_column :profiles, :col8a, :string
    add_column :profiles, :col9a, :string
    add_column :profiles, :col10a, :string
  end
end
