module V1
  class RegistrationsController < BaseController
    skip_before_filter :authenticate_user_with_token, :only => [:create ]
    respond_to :json

    def create
      user = User.new(user_params)
      if user.save
        user.assign_fresh_token!
        render :json=> {:auth_token=>user.token, :email=>user.email}, :status=>201
        return
      else
        warden.custom_failure!
        render :json=> user.errors, :status=>422
      end
    end

    private

    def user_params
      #Todo: add username
      params.require(:user).permit(:email, :password)
    end
  end
end
