module ApplicationHelper

  def auth
    session[:user_email] ? true : false
  end

  def authUser
    if auth
      Users.search(session[:user_email]).take
    else
      return false
    end
  end
end
