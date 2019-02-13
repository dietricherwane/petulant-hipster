class AddProfileSeparatorToParameters < ActiveRecord::Migration
  def change
    add_column :parameters, :profile_separator, :string
  end
end
