class Client
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :description,     type: String
  field :category,        type: String
  field :key,             type: String

  before_create :generate_special_key
  validates :name, presence: true, uniqueness: true

  private

  def generate_special_key
    self.key = Devise.friendly_token
  end
end
