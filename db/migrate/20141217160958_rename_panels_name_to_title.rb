class RenamePanelsNameToTitle < ActiveRecord::Migration
  def change
    rename_column :panels, :name, :title
  end
end
