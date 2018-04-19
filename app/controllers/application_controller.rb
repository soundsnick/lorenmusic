class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def auth
    session[:user_email] ? true : false
  end

  def check_admin
    @user = User.find_by(email: session[:user_email])
    @user.status == 1 ? true : false
  end

  def authUser
    if auth
      User.find_by(email: session[:user_email])
    else
      return false
    end
  end
end
