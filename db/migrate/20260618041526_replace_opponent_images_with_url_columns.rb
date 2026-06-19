class ReplaceOpponentImagesWithUrlColumns < ActiveRecord::Migration[8.1]
  def change
    remove_column :opponents, :sprite, :string

    5.times do |i|
      n = i + 1
      add_column :opponents, :"avatar_#{n}", :string
      add_column :opponents, :"cinematic_#{n}", :string
    end
  end
end
