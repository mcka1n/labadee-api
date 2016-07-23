class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id,         type: String
  field :name,            type: String      # This will have the title/word.
  field :description,     type: String
  field :address,         type: String
  field :zip,             type: String
  field :country,         type: String
  field :start_date,      type: DateTime
  field :end_date,        type: DateTime
  field :category,        type: String
  field :latitude,        type: String      # Todo: Use Geocode to get the real coordinates.
  field :longitude,       type: String
  field :hide,            type: Boolean, default: false
  field :rank,            type: Float, default: 0.00

  belongs_to :user
  has_many :attendees, :dependent => :destroy

  validates :name, presence: true, uniqueness: true
  validates :user_id, presence: true

  def self.search query
    if !query.blank?
      Event.all.where name: /#{query}/i
    else
      Event.all
    end
  end
end
