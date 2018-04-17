class Playlist < ActiveRecord::Migration[5.1]
  def change
    create_table :playlist do |t|
      t.integer :track_id
      t.integer :author_id
    end
  end
end
