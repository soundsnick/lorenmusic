class UsersController < ApplicationController
  require 'digest'

  def signup
    if auth
      redirect_to root_path, notice: 'Вы уже вошли'
    else
      @title = 'Регистрация'
      @pageTitle = @title
      render 'register'
    end
  end

  def signin
    if auth
      redirect_to root_path, notice: 'Вы уже вошли'
    else
      @active_link = 'login'
      @title = 'Войти'
      @pageTitle = @title
      render 'login'
    end
  end

  def register
    if form_params[:password] != form_params[:password_confirm]
      redirect_to register_view_path, notice: 'Пароли не совпадают'
    else
      @userEmail = Users.search(form_params[:email])
      if !@userEmail
        @user = Users.new(form_params.permit(:email, :name, :password))
        @user.save
        session[:user_email] = form_params[:email]
        redirect_to root_path, notice: 'Добро пожаловать, ' + form_params[:name]
      else
        redirect_to register_view_path, notice: 'Пользователь с данной электронной почтой уже зарегистрирован'
      end
    end
  end

  def login
    @user = Users.search(form_params[:email]).take
    if @user
      if @user.password == form_params[:password]
        session[:user_email] = form_params[:email]
        redirect_to root_path, notice: 'Добро пожаловать, ' + @user.name
      else
        loginError('Вы ввели неправильный пароль')
      end
    else
      loginError('Пользователь с такой электронной почтой не найден')
    end
  end

  def logout
    session[:user_email] = nil
    redirect_to root_path
  end

  def adminMake
    if check_owner
      @user = Users.find(params[:id])
      Users.update(params[:id], status: 0) if @user.status == 1
      if @user.status == 0 || @user.status.nil?
        Users.update(params.permit(:id)[:id], status: 1)
      end
      redirect_to admin_path
    else
      redirect_to root_path
    end
  end

  private

  def loginError(notice)
    redirect_to login_view_path(isError: 'error'), notice: notice
  end

  def form_params
    @formData = params.permit(:email, :password, :name, :password_confirm)
    @formData[:password] = Digest::SHA256.hexdigest @formData[:password]
    if @formData[:password_confirm]
      @formData[:password_confirm] = Digest::SHA256.hexdigest @formData[:password_confirm]
    end
    @formData
  end
end
