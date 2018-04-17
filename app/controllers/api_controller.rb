class ApiController < ApplicationController

  def tracks
    if params[:id]
      @track = Tracks.find(params[:id])
      @track = @track.as_json.merge('author_name' => Users.find(@track.author).name)
      render json: @track
    else
      render body: 'Params error: id is not defined'
    end
  end

  def playlistChange
    if params[:id]
      @user = Users.search(session[:user_email]).take
      if Playlist.exists?(author_id: @user.id, track_id: params[:id])
        @track = Playlist.where(author_id: @user.id, track_id: params[:id]).take
        Playlist.destroy(@track.id)
        render body: 'removed'
      else
        Playlist.new('author_id' => @user.id, 'track_id' => params[:id]).save
        render body: 'added'
      end
    end
  end

  def playlistCheck
    if params[:id]
      @user = Users.search(session[:user_email]).take
      if Playlist.exists?(author_id: @user.id, track_id: params[:id])
        render body: 'true'
      else
        render body: 'false'
      end
    end
  end
end