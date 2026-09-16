class Contact
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :email, :string
  attribute :message, :string
  attribute :nickname, :string # honeypot : champ caché, un humain ne le remplit jamais

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true

  # Un bot qui remplit le honeypot se trahit ; géré à part (pas une validation classique)
  # pour ne pas lui renvoyer d'erreur qui l'aiderait à s'adapter
  def spam?
    nickname.present?
  end
end
