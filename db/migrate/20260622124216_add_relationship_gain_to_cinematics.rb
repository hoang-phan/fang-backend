class AddRelationshipGainToCinematics < ActiveRecord::Migration[8.1]
  def change
    add_column :cinematics, :relationship_gain, :integer
  end
end
