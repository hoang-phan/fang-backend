class AddRoleToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :role, :integer
    add_index :chats, :role
  end
end
