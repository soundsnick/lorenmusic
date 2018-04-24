class RenameTypeApiAppsTwo < ActiveRecord::Migration[5.1]
  def change
    rename_column :api_apps, :appType, :platform
  end
end
