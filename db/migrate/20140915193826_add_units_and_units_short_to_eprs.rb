class AddUnitsAndUnitsShortToEprs < ActiveRecord::Migration
  def change
    add_column :entity_property_relationships, :units, :string
    add_column :entity_property_relationships, :units_short, :string
  end
end
