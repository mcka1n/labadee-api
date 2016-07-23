class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Geocoder::Model::Mongoid

  field :user_id,         type: String
  field :name,            type: String      # This will have the title/word.
  field :description,     type: String
  field :address,         type: String
  field :zip,             type: String
  field :country,         type: String
  field :start_date,      type: DateTime
  field :end_date,        type: DateTime
  field :category,        type: String
  field :hide,            type: Boolean, default: false
  field :rank,            type: Float, default: 0.00
  field :coordinates,     type: Array

  geocoded_by :address

  belongs_to :user
  has_many :attendees, :dependent => :destroy

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true
  after_validation :geocode, if: ->(obj){ obj.full_address.present? and obj.full_address_changed? }

  def self.search query
    if !query.blank?
      Event.all.where name: /#{query}/i
    else
      Event.all
    end
  end

  def full_address
    [address, zip, country].compact.join(', ')
  end

  def full_address_changed?
    address_changed? || zip_changed? || country_changed?
  end
end
