class CreateChats < ActiveRecord::Migration[8.1]
  def change
    create_table :chats do |t|
      t.references :conversation, null: false, foreign_key: true
      t.string     :avatar,       null: false
      t.integer    :position,     null: false, default: 0
      t.text       :content,      null: false

      t.timestamps
    end

    add_index :chats, [ :conversation_id, :position ]
  end
end
