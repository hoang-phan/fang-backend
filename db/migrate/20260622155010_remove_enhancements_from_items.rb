class RemoveEnhancementsFromItems < ActiveRecord::Migration[8.1]
  def change
    remove_column :items, :enhancements, :text
  end
end
