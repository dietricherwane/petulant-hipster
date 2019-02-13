class AddNumberOfColumnsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :number_of_columns, :integer
  end
end
