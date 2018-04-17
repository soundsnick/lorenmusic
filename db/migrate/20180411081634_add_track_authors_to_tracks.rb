class AddTrackAuthorsToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :lyrics_by, :string
    add_column :tracks, :music_by, :string
  end
end
