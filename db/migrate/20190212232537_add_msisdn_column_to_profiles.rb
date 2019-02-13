class AddMsisdnColumnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :msisdn_column, :integer
  end
end
