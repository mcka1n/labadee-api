class Attendee
  include Mongoid::Document
  include Mongoid::Timestamps

  field :status,          type: String

  belongs_to :event
  belongs_to :user

  index({ event_id: 1, user_id: 1 }, { unique: true })
  index({ user_id: 1 })

  validates :event_id, :uniqueness => { :scope => :user_id }
end
