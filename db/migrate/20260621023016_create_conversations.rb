class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.string :conversable_type, null: false
      t.string :conversable_id,   null: false

      t.timestamps
    end

    add_index :conversations, [ :conversable_type, :conversable_id ], unique: true
  end
end
