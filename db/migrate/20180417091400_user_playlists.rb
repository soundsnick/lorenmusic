class UserPlaylists < ActiveRecord::Migration[5.1]
  def change
    create_table :user_playlist do |t|
      t.integer :track_id
      t.integer :user_id
    end
  end
end
