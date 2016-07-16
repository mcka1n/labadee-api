Rails.application.routes.draw do
  scope '/v1' do
    devise_for :users, :controllers => {:registrations => "v1/registrations", :sessions => "v1/sessions"}, defaults: { format: "json" }
  end

  namespace :v1 do
    
  end

  root :to => redirect('/sign_in')
end
