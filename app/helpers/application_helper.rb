module ApplicationHelper

  def auth
    session[:user_email] ? true : false
  end

  def authUser
    if auth
      User.find_by(email: session[:user_email])
    else
      return false
    end
  end
end
