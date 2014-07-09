class AddIndexToEntityGroupRelationships < ActiveRecord::Migration
  def change
    add_index :entity_group_relationships, ["entity_id", "group_id"], :unique => true
  end
end
