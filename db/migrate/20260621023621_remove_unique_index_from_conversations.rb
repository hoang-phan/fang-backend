class RemoveUniqueIndexFromConversations < ActiveRecord::Migration[8.1]
  def change
    remove_index :conversations, [ :conversable_type, :conversable_id ]
    add_index :conversations, [ :conversable_type, :conversable_id ]
  end
end
