class AdaptPanelsToSeekr < ActiveRecord::Migration
  def change
    add_column :panels, :search_id, :integer
    remove_column :panels, :query, :string
  end
end
