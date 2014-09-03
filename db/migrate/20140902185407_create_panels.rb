class CreatePanels < ActiveRecord::Migration
  def change
    create_table :panels do |t|
      t.string :name
      t.string :slug,     :null => false
      t.string :query

      t.timestamps
    end
    add_index :panels, :slug, unique: true
  end
end
