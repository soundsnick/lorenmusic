class TracksController < ApplicationController
  def index
    @active_link = 'index'
    @New = Tracks.limit(5)
  end
end