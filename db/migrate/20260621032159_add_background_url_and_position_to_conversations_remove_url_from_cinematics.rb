class AddBackgroundUrlAndPositionToConversationsRemoveUrlFromCinematics < ActiveRecord::Migration[8.1]
  def change
    add_column :conversations, :background_url, :string
    add_column :conversations, :position, :integer

    remove_column :cinematics, :url, :string
  end
end
