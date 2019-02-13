class CreateProfileData < ActiveRecord::Migration
  def change
    create_table :profile_data do |t|
      t.integer :profile_id
      t.boolean :published
      t.string :col1
      t.string :col2
      t.string :col3
      t.string :col4
      t.string :col5
      t.string :col6
      t.string :col7
      t.string :col8
      t.string :col9
      t.string :col10

      t.timestamps
    end
  end
end
