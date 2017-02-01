class CustomLog < ActiveRecord::Base

  # Set accessible fields
  attr_accessible :sender_service, :message, :msisdn, :created_at

end
