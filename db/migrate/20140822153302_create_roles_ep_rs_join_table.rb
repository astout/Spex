class CreateRolesEpRsJoinTable < ActiveRecord::Migration
  def change
    create_table :eprs_roles, id: false do |t|
      t.integer :epr_id
      t.integer :role_id
    end

    add_index :eprs_roles, [:epr_id, :role_id], unique: true
  end
end
