class CreateOpponents < ActiveRecord::Migration[8.1]
  def change
    create_table :opponents, id: false do |t|
      t.string :slug, null: false, primary_key: true
      t.string :name, null: false
      t.string :sprite, null: false
      t.string :element_type, null: false, default: "normal"
      t.integer :max_hp, null: false, default: 100
      t.integer :base_damage, null: false, default: 10
      t.float :damage_variance, null: false, default: 0.2
      t.integer :gold_reward_min, null: false, default: 5
      t.integer :gold_reward_max, null: false, default: 15
      t.text :flavour_text
      t.integer :level, null: false, default: 1
      t.integer :xp_reward_victory, null: false, default: 50
      t.integer :xp_reward_defeat, null: false, default: 10
      t.text :unlock_after  # JSON array of opponent slugs

      t.timestamps
    end

    create_table :opponent_moves do |t|
      t.string :opponent_slug, null: false
      t.string :move_slug, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :opponent_moves, [ :opponent_slug, :position ]
    add_index :opponent_moves, [ :opponent_slug, :move_slug ], unique: true
  end
end
