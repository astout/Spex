class RenameEgrOrderAndEprOrder < ActiveRecord::Migration
  def change
    rename_column :entity_property_relationships, :order, :position
    rename_column :entity_group_relationships, :order, :position
    rename_column :group_property_relationships, :order, :position
  end
end
