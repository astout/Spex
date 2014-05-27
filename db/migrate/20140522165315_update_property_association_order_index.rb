class UpdatePropertyAssociationOrderIndex < ActiveRecord::Migration
  def change
    remove_index :property_associations, :order
    add_index :property_associations, [:parent_id, :order], unique: true
  end
end
