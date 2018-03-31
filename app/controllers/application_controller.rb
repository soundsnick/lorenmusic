class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def index
    @active_link = 'index'
    render 'index'
  end

  private

  def auth
    session[:user_email] ? true : false
  end
end
