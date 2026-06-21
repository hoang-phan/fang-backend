class CreateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :items, primary_key: :slug, id: :string do |t|
      t.string  :name,         null: false
      t.string  :icon,         null: false
      t.string  :category,     null: false
      t.string  :quality,      null: false, default: "normal"
      t.integer :base_damage
      t.integer :base_defense
      t.text    :enhancements, null: false, default: "[]"

      t.timestamps
    end
  end
end
