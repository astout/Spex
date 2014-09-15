class CreateRolePropertiesJoinTable < ActiveRecord::Migration
  def change
    create_table :properties_roles, id: false do |t|
      t.integer :property_id
      t.integer :role_id
    end

    add_index :properties_roles, [:property_id, :role_id], unique: true
  end
end
