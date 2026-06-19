class MakeIconNullableOnMoves < ActiveRecord::Migration[8.1]
  def change
    change_column_null :moves, :icon, true
  end
end
