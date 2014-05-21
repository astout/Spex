class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name
      t.string :units
      t.string :units_short
      t.string :type

      t.timestamps
    end
    add_index :properties, [:name]
  end
end
