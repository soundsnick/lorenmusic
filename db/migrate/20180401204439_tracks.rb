class Tracks < ActiveRecord::Migration[5.1]
  def change
    create_table :tracks do |t|
      t.string :title
      t.integer :album
      t.integer :author
      t.text :img
      t.text :file
      t.timestamps
    end
  end
end
