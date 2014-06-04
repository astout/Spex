class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name
      t.string :units
      t.string :units_short
      t.string :default_label
      t.string :default_value
      t.integer :default_visibility

      t.timestamps
    end
    add_index :properties, [:name], unique: true
  end
end
