class RedesignGiftsAsPerOpponent < ActiveRecord::Migration[8.1]
  def change
    drop_table :gifts

    create_table :gifts do |t|
      t.string  :opponent_slug, null: false
      t.string  :name,          null: false
      t.integer :gold,          null: false, default: 0
      t.integer :exp,           null: false, default: 0

      t.timestamps
    end

    add_index :gifts, :opponent_slug
  end
end
