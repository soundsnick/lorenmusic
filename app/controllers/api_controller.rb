# Api Controller
class ApiController < ApplicationController
  def index
    @page_title = 'Close API'
  end

  def user_all
    if authentificationCheck == true
      @users = User.all
      responseMethod(200, 'succesful_get', 'All users', @users)
    end
  end

  def user_search
    if authentificationCheck == true
      if params[:email]
        if (user = User.find_by(email: params[:email]))
          responseMethod(200, 'search_success', 'User info', user)
        else
          responseMethod(203, 'user_not_found', 'No user with that email', {})
        end
      else
        responseMethod(403, 'null_params', 'Email is not defined', {})
      end
    end
  end

  def user_auth
    require 'digest'
    if authentificationCheck == true
      if params[:email] && params[:password]
        if (user = User.find_by(email: params[:email]))
          password = Digest::SHA256.hexdigest params[:password]
          if password == user.password
            responseMethod(200, 'login_success', 'User successfully signed in', user)
          else
            responseMethod(200, 'incorrect_password', 'Incorrect password', {})
          end
        else
          responseMethod(203, 'user_not_found', 'No user with that email', {})
        end
      else
        responseMethod(403, 'null_params',  'Email or password is not defined', {})
      end
    end
  end

  def tracks_all
    if authentificationCheck == true
      @tracks = Track.all
      responseMethod(200, 'successful_get', 'Tracks', @tracks)
    end
  end

  def tracks_find
    if authentificationCheck == true
      if params[:id]
        if (@track = Track.find_by(id: params[:id]))
          @track = @track.as_json.merge('author_name' => User.find(@track.author).name)
          responseMethod(200, 'successful_get', 'Track', @track)
        else
          responseMethod(203, 'error_get', 'Track not found', {})
        end
      else
        responseMethod(403, 'null_params', 'id is not defined', {})
      end
    end
  end

  def playlist_change
    if authentificationCheck == true
      unless params[:id] && params[:user_id]
        responseMethod(203, 'user_not_found', 'User is not found', {})
        exit
      end
      if (@user = User.find_by(id: params[:user_id]))
        if (@track = Playlist.find_by(author_id: @user.id, track_id: params[:id]))
          Playlist.destroy(@track.id)
          responseMethod(200, 'successful_remove', 'Track successfully removed from user\'s playlist', {})
        else
          Playlist.new('author_id' => @user.id, 'track_id' => params[:id]).save
          responseMethod(200, 'successful_add', 'Track successfully added to user\'s playlist', {})
        end
      else
        responseMethod(403, 'null_params', 'id or user_id is not defined', {})
      end
    end
  end

  def playlist_check
    if params[:id] && params[:user_id]
      if (@user = User.find_by(id: params[:user_id]))
        if Playlist.exists?(author_id: @user['id'], track_id: params[:id])
          responseMethod(200, 'track_exist', 'Track belongs to playlist', {})
        else
          responseMethod(200, 'track_not_exist', 'Track doesn\'t belong to playlist', {})
        end
      else
        responseMethod(203, 'user_not_found', 'User is not found', {})
      end
    else
      responseMethod(403, 'null_params', 'id or user_id is not defined', {})
    end
  end

  private

  def authentificationCheck
    if params[:access_token]
      if ApiApp.find_by(access_token: params[:access_token]) then
        true
      else
        responseMethod(203, 'auth_fail', 'Server didn\'t let you in because of the lack of your access token in Database', {})
      end
    else
      responseMethod(403, 'no_access_token', 'No access token send in parameters', {})
    end
  end

  def responseMethod(status, message, description, obj)
    responseHash = {
      headers: {
        status: status,
        format: 'json'
      },
      app: ApiApp.find_by(access_token: params[:access_token]),
      body: {
          message: message,
          description: description,
          object: obj
        }
    }
    render json: responseHash
  end
end