class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def auth
    session[:user_email] ? true : false
  end

  def check_admin
    @user = Users.search(session[:user_email]).take
    @user.status == 1 ? true : false
  end

  def authUser
    if auth
      Users.search(session[:user_email]).take
    end
    else return false
  end
end
