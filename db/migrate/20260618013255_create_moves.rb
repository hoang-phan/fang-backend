class CreateMoves < ActiveRecord::Migration[8.1]
  def change
    create_table :moves, id: false do |t|
      t.string :slug, null: false, primary_key: true
      t.string :name, null: false
      t.string :icon, null: false
      t.text :description
      t.string :element_type, null: false, default: "normal"
      t.integer :mp_cost, null: false, default: 0
      t.integer :base_damage, null: false, default: 0
      t.float :damage_variance, null: false, default: 0.2
      t.integer :level, null: false, default: 1
      t.integer :max_level, null: false, default: 5

      t.timestamps
    end
  end
end
