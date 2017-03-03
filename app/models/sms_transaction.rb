class SmsTransaction < ActiveRecord::Base
  # Relationships
  has_many :message_logs
  belongs_to :profile
  belongs_to :user
  # Set accessible fields
  attr_accessible :started_at, :ended_at, :profile_id, :description, :send_messages, :failed_messages, :number_of_messages, :created_at, :sender_service, :user_id, :service_id

  # Renaming attributes into more friendly text
  HUMANIZED_ATTRIBUTES = {
    started_at: "Date de début",
    ended_at: "Date de fin",
    profile_id: "Profil",
    description: "Description",
    send_messages: "Message envoyés",
    failed_messages: "Messages échoués",
    number_of_messages: "Nombre de messages"
  }

  def self.human_attribute_name(attr, option = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations

end
