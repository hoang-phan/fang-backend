class ReplaceRoleWithSpeakerOnChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :speaker, :string, null: false, default: ""
    remove_index :chats, :role
    remove_column :chats, :role, :integer
  end
end
