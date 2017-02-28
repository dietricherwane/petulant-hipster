class Customer < ActiveRecord::Base
  # Set accessible fields
  attr_accessible :label, :uuid, :login, :password, :service_id, :sender, :user_id, :status, :id
  #attr_encrypted :encrypted_password

  # Relationships
  belongs_to :user
  has_many :message_logs

  # Renaming attributes into more friendly text
  HUMANIZED_ATTRIBUTES = {
    user_id: "L'utilisateur",
    label: "Libellé",
    login: "Login",
    password: "Mot de passe",
    sender: "Emetteur",
    status: "Statut"
  }

  def self.human_attribute_name(attr, option = {})
    HUMANIZED_ATTRIBUTES[attr.to_sym] || super
  end

  # Validations
  validates :user_id, :label, :login ,:password, presence: true
  validates :label, uniqueness: true
end
