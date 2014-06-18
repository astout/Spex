class CreateGroupPropertyRelationships < ActiveRecord::Migration
  def change
    create_table :group_property_relationships do |t|
      t.integer :group_id
      t.integer :property_id
      t.integer :order

      t.timestamps
    end
  end
end
