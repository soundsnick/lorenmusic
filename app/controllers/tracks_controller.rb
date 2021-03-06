# class: TrackController
class TracksController < ApplicationController
  require 'digest'

  def index
    @page_title = 'Главная'
    @active_link = 'index'
    @new = Track.limit(3)
  end

  def getTrack
    if params[:id]
      require 'unirest'

      @track = Track.find(params[:id])
      @track = @track.as_json.merge('author_name' => User.find(@track.author).name)

      @page_title = @track['title']
      render 'track'
    else
      redirect_to root_path
    end
  end

  def add
    if addParams[:file].nil?
      @track = addParams
      redirect_to track_new_view_path(isError: 'error'), notice: 'Добавьте композицию'
    else
      if addParams[:title] == ''
        @track = addParams
        redirect_to track_new_view_path(isError: 'error'), notice: 'Добавьте название композиции'
      else
        uploaded_img = addParams[:img]
        uploaded_pdf = addParams[:file]
        hashKey = Digest::SHA256.hexdigest addParams[:title]
        unless uploaded_img.nil?
          File.open(Rails.root.join('public', 'covers', uploaded_img.original_filename + hashKey), 'wb') do |file|
            file.write(uploaded_img.read)
          end
        end
        File.open(Rails.root.join('public', 'files', uploaded_pdf.original_filename + hashKey), 'wb') do |file|
          file.write(uploaded_pdf.read)
        end

        form_params = addParams
        unless uploaded_img.nil?
          form_params[:img] = uploaded_img.original_filename + hashKey
        end

        form_params[:file] = uploaded_pdf.original_filename + hashKey
        @author = User.find_by(email: session[:user_email])
        form_params[:author] = @author.id
        @track = Track.new(form_params)
        @track.save
        redirect_to root_path, notice: 'Композиция ' + form_params[:title] + ' была добавлена'
      end
    end
  end

  def addView
    @page_title = 'Добавить трек'
    render 'new'
  end

  def search
    @page_title = 'Поиск: ' + params[:query]
    @tracks = Track.search(params[:query])
  end

  def playlist
    if auth
      @page_title = 'Мой плейлист'
      @user = User.find_by(email: session[:user_email])
      tracksFromPlaylist = Playlist.search(@user.id)
      trackIds = []
      tracksFromPlaylist.each do |pl|
        trackIds.push(pl.track_id)
      end
      @tracks = []
      trackIds.each do |track|
        @tracks.push(Track.find(track))
      end
    else
      redirect_to login_view_path, notice: 'Войдите для просмотра этой страницы'
    end
  end

  def userTracks
    author = User.find(params[:id])
    @page_title = 'Треки ' + author.name
    @tracks = Track.searchByAuthor(author.id)
    render 'playlist'
  end

  private

  def addParams
    params.require(:track).permit(:title, :album, :lyrics_by, :music_by, :img, :file, :lyrics)
  end
end