class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def auth
    session[:user_email] ? true : false
  end
end
