class AddIndexToGroupPropertyRelationships < ActiveRecord::Migration
  def change
    add_index :group_property_relationships, :group_id
    add_index :group_property_relationships, :property_id
    add_index :group_property_relationships, ["group_id", "property_id"], :unique => true
  end
end
