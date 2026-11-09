module V1
  class AttendeesController < BaseController
    before_action :load_event

    def index
      render json: @event.attendees
    end

    def show
      attendee = @event.attendees.where(id: params[:id]).first if document_id?(params[:id])
      if attendee
        render json: attendee
      else
        render json: {}, status: 404
      end
    end

    def create
      attendee = Attendee.new(event: @event, user: current_user)
      if attendee.save
        render json: attendee
      else
        render json: attendee.errors, status: 422
      end
    rescue Mongo::Error::OperationFailure => error
      raise unless error.code == 11000

      attendee.errors.add(:event_id, :taken)
      render json: attendee.errors, status: 422
    end

    private

    def load_event
      @event = Event.where(id: params[:event_id]).first if document_id?(params[:event_id])
      render json: (action_name == 'index' ? [] : {}), status: 404 unless @event
    end
  end
end
