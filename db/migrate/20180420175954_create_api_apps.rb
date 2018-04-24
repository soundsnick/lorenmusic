class CreateApiApps < ActiveRecord::Migration[5.1]
  def change
    drop_table :api_apps

    create_table :api_apps do |t|
      t.string :name
      t.string :type
      t.string :contacts
      t.string :access_token
    end
  end
end
