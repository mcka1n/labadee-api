module V1
  class AttendeesController < BaseController
    def index
      event = Event.where(id: params[:event_id]).first

      if event.present?
        render json: event.attendees
      else
        render json: [], status: 404
      end
    end

    def show
      attendee = Attendee.where(id: params[:id]).first
      if attendee.present?
        render json: attendee
      else
        render json: {}, status: 404
      end
    end

    def create
      result = {}
      event = Event.where(id: params[:event_id]).first
      attendee = Attendee.create(
        user_id: current_user.id,
        event_id: event.id
      )

      if attendee.errors.messages.empty?
        result = attendee
        render json: result
      else
        result = attendee.errors
        render json: result, status: 422
      end
    end
  end
end
