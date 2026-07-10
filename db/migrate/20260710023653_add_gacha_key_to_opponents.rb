class AddGachaKeyToOpponents < ActiveRecord::Migration[8.1]
  def up
    add_column :opponents, :gacha_key, :string

    Opponent.reset_column_information
    Opponent.find_each do |opponent|
      opponent.update_column(:gacha_key, SecureRandom.urlsafe_base64(16))
    end

    change_column_null :opponents, :gacha_key, false
    add_index :opponents, :gacha_key, unique: true
  end

  def down
    remove_index :opponents, :gacha_key
    remove_column :opponents, :gacha_key
  end
end
