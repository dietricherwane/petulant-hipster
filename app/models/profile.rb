class Profile < ActiveRecord::Base
  # Relationships
  has_many :subscribers
  has_many :sms_transactions
  belongs_to :customer
  belongs_to :user
  has_many :profile_data

  # Set accessible fields
  attr_accessible :name, :published, :col1a, :col2a, :col3a, :col4a, :col5a, :col6a, :col7a, :col8a, :col9a, :col10a, :number_of_columns, :aliases, :msisdn_column

  # Renaming attributes into more friendly text
  HUMANIZED_ATTRIBUTES = {
    name: "Nom"
  }

  def self.human_attribute_name(attr, option = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :name, presence: true
  validates :name, uniqueness: true

  # Custom functions
  def self.pmu_profile_id
    where(name: "PMU").first.id rescue nil
  end

  def self.loto_bonheur_profile_id
    where(name: "LOTO BONHEUR").first.id rescue nil
  end
end
