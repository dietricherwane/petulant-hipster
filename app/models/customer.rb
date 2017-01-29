class Customer < ActiveRecord::Base
  # Set accessible fields
  attr_accessible :label, :uuid, :login, :password
end
