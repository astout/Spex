class RemoveEntityPropertyRelationshipOrderIndex < ActiveRecord::Migration
  def change
    remove_index :entity_property_relationships, name: 'index_entity_order_unique_pair'
  end
end
