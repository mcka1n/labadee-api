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
      event = Event.create(
        user_id: current_user.id,
        name: params[:name],
        description: params[:description],
        address: params[:address],
        zip: params[:zip],
        country: params[:country],
        start_date: params[:start_date],
        end_date: params[:end_date],
        category: params[:category]
      )

      if event.errors.messages.empty?
        result = event
        render json: result
      else
        result = event.errors
        render json: result, status: 422
      end
    end
  end
end
