class AddMoreStatsToMoves < ActiveRecord::Migration[8.1]
  def change
    add_column :moves, :base_defense, :integer
    add_column :moves, :effect_turns, :integer
    add_column :moves, :effect_damage, :integer
    add_column :moves, :effect_prob, :float
    add_column :moves, :effect_stun, :boolean
    add_column :moves, :leech, :float
  end
end
