class Customer < ActiveRecord::Base
  # Set accessible fields
  attr_accessible :label, :uuid, :login, :password, :service_id, :sender, :user_id, :status, :id, :md5_password, :sms_provider_id, :bulk, :bulk_email, :sms_allowed, :email_allowed
  #attr_encrypted :encrypted_password

  # Relationships
  belongs_to :user
  has_many :message_logs
  belongs_to :sms_provider

  # Renaming attributes into more friendly text
  HUMANIZED_ATTRIBUTES = {
    user_id: "L'utilisateur",
    label: "Service ID",
    login: "Login",
    password: "Mot de passe",
    sender: "Emetteur",
    status: "Statut",
    sms_provider_id: "Fournisseur SMS",
    bulk: "Bulk SMS",
    bulkemail: "Blk Email",
    sms_allowed: "Sms autorisés",
    email_allowed: "Emails autorisés"
  }

  def self.human_attribute_name(attr, option = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :user_id, :label, :sms_provider_id, :login, :password, presence: true
  validates :label, uniqueness: true
  validates :bulk, numericality: {greater_than_or_equal_to: 0}
end
