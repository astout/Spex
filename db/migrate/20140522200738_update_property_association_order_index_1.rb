class UpdatePropertyAssociationOrderIndex1 < ActiveRecord::Migration
  def change
    remove_index :property_associations, [:parent_id, :order]
  end
end
