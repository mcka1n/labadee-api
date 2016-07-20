class Attendee
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_id,         type: String
  field :event_id,        type: String
  field :status,          type: String

  belongs_to :event
  belongs_to :user

  validates :event_id, :uniqueness => { :scope => :user_id }
end
