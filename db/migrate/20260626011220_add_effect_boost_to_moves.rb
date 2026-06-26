class AddEffectBoostToMoves < ActiveRecord::Migration[8.1]
  def change
    add_column :moves, :effect_boost_percent, :integer
    add_column :moves, :effect_boost_kind, :integer, default: 0
  end
end
