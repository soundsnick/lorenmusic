class Albums < ActiveRecord::Migration[5.1]
  def change
    create_table :albums do |t|
      t.string :title
      t.integer :author
      t.text :img
      t.timestamps
    end
  end
end
