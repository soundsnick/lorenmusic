class TracksController < ApplicationController
  require 'digest'

  def index
    @pageTitle = 'Главная'
    @active_link = 'index'
    @new = Tracks.limit(8)
  end
  def getTrack
    if params[:id]
      require 'unirest'

      @track = Tracks.find(params[:id])
      @pageTitle = @track.title
      @track = @track.as_json.merge('author_name' => Users.find(@track.author).name)
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
        @hashKey = Digest::SHA256.hexdigest addParams[:title]
        unless uploaded_img.nil?
          File.open(Rails.root.join('public', 'covers', uploaded_img.original_filename + @hashKey), 'wb') do |file|
            file.write(uploaded_img.read)
          end
        end
        File.open(Rails.root.join('public', 'files', uploaded_pdf.original_filename + @hashKey), 'wb') do |file|
          file.write(uploaded_pdf.read)
        end

        form_params = addParams
        unless uploaded_img.nil?
          form_params[:img] = uploaded_img.original_filename + @hashKey
        end

        form_params[:file] = uploaded_pdf.original_filename + @hashKey
        @author = Users.search(session[:user_email]).take
        form_params[:author] = @author.id
        @track = Tracks.new(form_params)
        @track.save
        redirect_to root_path, notice: 'Композиция ' + form_params[:title] + ' была добавлена'
      end
    end
  end

  def addView
    @pageTitle = 'Добавить трек'
    render 'new'
  end

  def search
    @pageTitle = 'Поиск: ' + params[:query]
    @tracks = Tracks.search(params[:query])
  end

  def playlist
    if auth
      @pageTitle = 'Мой плейлист'
      @user = Users.search(session[:user_email]).take
      @tracksFromPlaylist = Playlist.search(@user.id)
      @trackIds = []
      @tracksFromPlaylist.each do |pl|
        @trackIds.push(pl.track_id)
      end
      @tracks = []
      @trackIds.each do |track|
        @tracks.push(Tracks.find(track))
      end
    else
      redirect_to login_view_path, notice: 'Войдите для просмотра этой страницы'
    end
  end

  private

  def addParams
    params.require(:@track).permit(:title, :album, :lyrics_by, :music_by, :img, :file, :lyrics)
  end
end