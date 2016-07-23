module V1
  class EventsController < BaseController
    def index
      events = Event.all
      render json: events
    end

    def show
      event = Event.where(id: params[:id]).first
      if event.present?
        render json: event
      else
        render json: {}, status: 404
      end
    end

    def create
      result = {}
      event = Event.new(event_params)
      event.user_id = current_user.id
      event.save

      if event.errors.messages.empty?
        result = event
        render json: result
      else
        result = event.errors
        render json: result, status: 422
      end
    end

    def update
      event = Event.where(id: params[:id]).first
      event.update_attributes(event_params)

      render json: event
    end

    private

    def event_params
      params.required(:event).permit!
    end
  end
end
