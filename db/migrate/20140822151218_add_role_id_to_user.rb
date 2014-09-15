class AddRoleIdToUser < ActiveRecord::Migration
  def change
    remove_column :users, :role, :integer
    add_column :users, :role_id, :integer
  end
end
