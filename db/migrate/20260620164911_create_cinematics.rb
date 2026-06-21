class CreateCinematics < ActiveRecord::Migration[8.1]
  def change
    create_table :cinematics do |t|
      t.string  :opponent_slug, null: false
      t.integer :level,         null: false
      t.text    :description
      t.string  :url,           null: false

      t.timestamps
    end

    add_index :cinematics, [ :opponent_slug, :level ], unique: true
  end
end
