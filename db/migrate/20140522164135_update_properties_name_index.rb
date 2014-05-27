class UpdatePropertiesNameIndex < ActiveRecord::Migration
  def change
    remove_index :properties, :name
    add_index :properties, :name, unique: true
  end
end
