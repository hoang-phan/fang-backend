class CleanupGoldAndXpRewardsOnOpponents < ActiveRecord::Migration[8.1]
  def change
    remove_column :opponents, :gold_reward_min, :integer
    remove_column :opponents, :gold_reward_max, :integer
    remove_column :opponents, :xp_reward_victory, :integer
    remove_column :opponents, :xp_reward_defeat, :integer
    add_column :opponents, :gold_reward, :integer
    add_column :opponents, :xp_reward, :integer
  end
end
