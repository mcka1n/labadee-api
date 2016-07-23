class EventSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :description, :address, :zip, :country,
    :start_date, :end_date, :category, :coordinates, :rank,
    :hide, :attendees, :created_at, :updated_at

  has_many :attendees

  def id
   object._id.to_s
  end

  def user_id
    object.user_id.to_s
  end
end
