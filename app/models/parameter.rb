class Parameter < ActiveRecord::Base
  # Set accessible fields
  attr_accessible :sms_provider_url, :sms_provider_token, :routesms_provider_url, :routesms_provider_username, :routesms_provider_password, :infobip_provider_username, :infobip_provider_password, :infobip_provider_url
end
