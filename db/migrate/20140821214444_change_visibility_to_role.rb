class ChangeVisibilityToRole < ActiveRecord::Migration
  def change
    remove_column :properties, :default_visibility
    remove_column :entity_property_relationships, :visibility
  end
end
