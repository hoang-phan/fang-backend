class AddBackgroundColorToConversations < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :background_color, :string
  end
end
