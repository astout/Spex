class CreateEntityPropertyRelationships < ActiveRecord::Migration
  def change
    create_table :entity_property_relationships do |t|
      t.integer :entity_id
      t.integer :property_id
      t.integer :group_id
      t.integer :order
      t.string :label
      t.string :value
      t.integer :visibility

      t.timestamps
    end
  end
end
