class CreateGifts < ActiveRecord::Migration[8.1]
  def change
    create_table :gifts, primary_key: :slug, id: :string do |t|
      t.string  :name, null: false
      t.integer :gold, null: false, default: 0
      t.integer :exp,  null: false, default: 0

      t.timestamps
    end
  end
end
