class CreateSprites < ActiveRecord::Migration[8.1]
  def change
    create_table :sprites do |t|
      t.string :url
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height
      t.references :spriteable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
