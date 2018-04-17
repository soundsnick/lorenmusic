class AddRemoteTrackIdToTracks < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :remote_id, :string
  end
end
