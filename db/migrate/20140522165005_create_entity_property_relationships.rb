class CreateEntityPropertyRelationships < ActiveRecord::Migration
  def change
    create_table :entity_property_relationships do |t|
      t.integer :entity_id
      t.integer :property_id
      t.integer :order
      t.string :label
      t.string :value
      t.integer :visibility

      t.timestamps
    end
    add_index :entity_property_relationships, :entity_id
    add_index :entity_property_relationships, :property_id
    add_index :entity_property_relationships, [:entity_id, :property_id], unique: true, name: 'index_entity_property_unique_pair'
    add_index :entity_property_relationships, [:entity_id, :order], unique: true, name: 'index_entity_order_unique_pair'
  end
end
