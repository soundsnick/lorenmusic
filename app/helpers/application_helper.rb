module ApplicationHelper

  def auth
    session[:user_email] ? true : false
  end
end
