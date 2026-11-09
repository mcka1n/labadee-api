module V1
  class EventsController < BaseController
    before_action :load_event, only: [:show, :update, :destroy]
    before_action :authorize_owner, only: [:update, :destroy]

    def index
      render json: Event.all
    end

    def show
      render json: @event
    end

    def create
      event = Event.new(event_params)
      event.user = current_user
      if event.save
        render json: event
      else
        render json: event.errors, status: 422
      end
    end

    def update
      if @event.update(event_params)
        render json: @event
      else
        render json: @event.errors, status: 422
      end
    end

    def destroy
      @event.destroy
      head :no_content
    end

    private

    def load_event
      @event = Event.where(id: params[:id]).first if document_id?(params[:id])
      render json: {}, status: 404 unless @event
    end

    def authorize_owner
      render json: { message: 'Forbidden' }, status: 403 unless @event.user_id == current_user.id
    end

    def event_params
      params.require(:event).permit(:name, :description, :address, :zip, :country,
        :start_date, :end_date, :category, :hide, :rank, coordinates: [])
    end
  end
end
