class ApplicationController < ActionController::API
  before_action :authenticate_client
  before_action :authenticate_user_with_token

  respond_to :json

  protected

  def authenticate_client
    key = params[:key]
    @current_client = Client.where(key: key).first if key.is_a?(String) && key.present?
    render json: { message: 'Invalid Client Key' }, status: :unauthorized unless @current_client
  end

  def authenticate_user_with_token
    token = params[:token]
    @current_user = User.where(token: token).first if token.is_a?(String) && token.present?
    render json: { message: 'Invalid token' }, status: :unauthorized unless @current_user
  end

  def document_id?(value)
    value.is_a?(String) && BSON::ObjectId.legal?(value)
  end
end
