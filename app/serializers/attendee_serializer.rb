class AttendeeSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :event_id, :status, :created_at, :updated_at

  def id
   object._id.to_s
  end

  def user_id
    object.user_id.to_s
  end

  def event_id
    object.event_id.to_s
  end
end
