class CleanupAvatarAndCinematicsFieldsOnOpponents < ActiveRecord::Migration[8.1]
  def change
    remove_column :opponents, :avatar_1, :string
    remove_column :opponents, :avatar_2, :string
    remove_column :opponents, :avatar_3, :string
    remove_column :opponents, :avatar_4, :string
    remove_column :opponents, :avatar_5, :string
    remove_column :opponents, :cinematic_1, :string
    remove_column :opponents, :cinematic_2, :string
    remove_column :opponents, :cinematic_3, :string
    remove_column :opponents, :cinematic_4, :string
    remove_column :opponents, :cinematic_5, :string
    add_column :opponents, :avatar, :string
  end
end
