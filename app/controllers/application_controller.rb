class ApplicationController < ActionController::API
  before_filter :authenticate_client
  before_filter :authenticate_user_with_token

  respond_to :json

  protected

  def authenticate_client
    @current_client ||= Client.where(key: params[:key]).first
    if !@current_client
      render json: {message: "Invalid Client Key"}, status: :unauthorized
    end
  end

  def authenticate_user_with_token
    if params[:token] && user = User.where(token: params[:token]).first
      @current_user = user
    else
      render json: {message: "Invalid token"}, status: :unauthorized
    end
  end
end
