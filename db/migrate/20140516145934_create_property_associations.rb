class CreatePropertyAssociations < ActiveRecord::Migration
  def change
    create_table :property_associations do |t|
      t.integer :parent_id
      t.integer :child_id
      t.integer :order

      t.timestamps
    end
    add_index :property_associations, :parent_id
    add_index :property_associations, :child_id
    add_index :property_associations, [:parent_id, :child_id], unique: true
    add_index :property_associations, :order, unique: true
  end
end
