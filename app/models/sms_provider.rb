class SmsProvider < ActiveRecord::Base
  #Relationships
  has_many :customers

  # Set accessible fields
  attr_accessible :label

  validates :label, uniqueness: true
end
