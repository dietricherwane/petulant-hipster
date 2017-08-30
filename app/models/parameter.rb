class Parameter < ActiveRecord::Base
  # Set accessible fields
  attr_accessible :sms_provider_url, :sms_provider_token
end
