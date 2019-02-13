class AddRowContentToProfileData < ActiveRecord::Migration
  def change
    add_column :profile_data, :row_content, :text
  end
end
