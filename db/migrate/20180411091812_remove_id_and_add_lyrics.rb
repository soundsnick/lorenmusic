class RemoveIdAndAddLyrics < ActiveRecord::Migration[5.1]
  def change
    add_column :tracks, :lyrics, :string
    remove_column :tracks, :remote_id
  end
end
