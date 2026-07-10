class AddRarityToOpponents < ActiveRecord::Migration[8.1]
  def change
    add_column :opponents, :rarity, :integer, null: false, default: 0
  end
end
