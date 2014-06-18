class CreateEntityGroupRelationships < ActiveRecord::Migration
  def change
    create_table :entity_group_relationships do |t|
      t.integer :entity_id
      t.integer :group_id
      t.integer :order
      t.string :label

      t.timestamps
    end
  end
end
