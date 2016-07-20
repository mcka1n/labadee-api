module V1
  class EventsController < BaseController
    def index
      events = Event.all
      render json: events
    end

    def show
      event = Event.where(id: params[:id]).first
      render json: event
    end

    def create
      result = {}
      # event = Event.find_or_create_by(user_id: current_user.id, name: params[:name], description: params[:description])
      if event.errors.messages.empty?
        result = event
      else
        result = event.errors
      end
      render json: result
    end
  end
end
