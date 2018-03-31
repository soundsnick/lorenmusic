class UsersController < ApplicationController
  require 'digest'
  def signup
    if check_auth
      redirect_to root_path, notice: 'Вы уже вошли'
    end
    @action = 'register'
    @method = 'get'
    @title = 'Регистрация'
    @pageTitle = @title
    render 'index'
  end

  def signin
    if session[:current_user_email] && session[:current_user_email] == 'soundsnick@gmail.com'
      redirect_to root_path, notice: 'Вы уже вошли'
    end
    @action = 'login'
    @method = 'post'
    @title = 'Войти'
    @pageTitle = @title
    render 'index'
  end

  def register
    @userEmail = Users.search(form_params[:email])
    if !@userEmail
      @user = Users.new(form_params)
      @user.save
      session[:current_user_email] = form_params[:email]
      redirect_to root_path, notice: 'Добро пожаловать, ' + form_params[:email]
    else
      redirect_to signupPage_path, notice: 'User with that email already exist'
    end
  end

  def admin
    if check_owner
      @pageTitle = 'Управление'
      @users = Users.all
    else
      redirect_to root_path
    end
  end

  def login
    @user = Users.search(form_params[:email])
    if @user
      if @user.password == form_params[:password]
        session[:current_user_email] = form_params[:email]
        redirect_to root_path, notice: 'Добро пожаловать, ' + form_params[:email]
      else
        loginError('Вы ввели неправильный пароль')
      end
    else
      loginError('Пользователь с такой электронной почтой не найден')
    end
  end

  def logout
    session[:current_user_email] = nil
    redirect_to root_path
  end

  def adminMake
    if check_owner
      @user = Users.find(params[:id])
      if @user.status == 1
        Users.update(params[:id], :status => 0)
      end
      if @user.status == 0 || @user.status == nil
        Users.update(params.permit(:id)[:id], :status => 1)
      end
      redirect_to admin_path
    else
      redirect_to root_path
    end
  end

  private

  def loginError(notice)
    redirect_to loginPage_path(:isError => 'error'), notice: notice
  end

  def form_params
    @formData = params.require(:login).permit(:email, :password)
    @formData[:password] = Digest::SHA256.hexdigest @formData[:password]
    @formData
  end
end
