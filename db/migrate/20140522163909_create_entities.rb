class CreateEntities < ActiveRecord::Migration
  def change
    create_table :entities do |t|
      t.string :name
      t.string :label
      t.string :img

      t.timestamps
    end
    add_index :entities, :name, unique: true
  end
end
