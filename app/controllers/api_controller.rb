class ApiController < ApplicationController

  def index
    @pageTitle = 'Open API'
  end

  def user_search
    if params[:email]
      if user = User.find_by(email: params[:email])
        response = {}
        response[:status] = 200
        response[:body] = user
        render json: response
      else
        response = {}
        response[:status] = 200
        response[:body] = {:message => 'not_found'}
        render json: response
      end
    else
      response = {}
      response[:status] = 403
      response[:body] = {:message => 'email_not_defined'}
      render json: response
    end
  end

  def tracks_all
    @tracks = Track.all
    render json: @tracks
  end

  def tracks_find
    if params[:id]
      @track = Track.find(params[:id])
      @track = @track.as_json.merge('author_name' => User.find(@track.author).name)
      render json: @track
    else
      render body: 'Params error: id is not defined'
    end
  end

  def playlist_change
    if auth
      if params[:id]
        @user = authUser
        if Playlist.exists?(author_id: @user.id, track_id: params[:id])
          @track = Playlist.where(author_id: @user.id, track_id: params[:id]).take
          Playlist.destroy(@track.id)
          render body: 'removed'
        else
          Playlist.new('author_id' => @user.id, 'track_id' => params[:id]).save
          render body: 'added'
        end
      end
    else
      render body: 'unauth'
    end
  end

  def playlist_check
    if auth
      if params[:id]
        @user = authUser
        if Playlist.exists?(author_id: @user['id'], track_id: params[:id])
          render body: 'true'
        else
          render body: 'false'
        end
      end
    else
      render body: 'unauth'
    end
  end
end