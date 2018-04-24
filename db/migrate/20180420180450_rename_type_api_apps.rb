class RenameTypeApiApps < ActiveRecord::Migration[5.1]
  def change
    rename_column :api_apps, :type, :appType
  end
end
