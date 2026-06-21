class RemoveAvatarFromChats < ActiveRecord::Migration[8.1]
  def change
    remove_column :chats, :avatar, :string
  end
end
