class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :sms_provider_url

      t.timestamps
    end
  end
end
