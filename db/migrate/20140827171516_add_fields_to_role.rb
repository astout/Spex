class AddFieldsToRole < ActiveRecord::Migration
  def change
    add_column :roles, :default, :boolean
    add_column :roles, :change_view, :boolean
    add_column :roles, :admin, :boolean

    remove_column :users, :admin, :boolean
  end
end
