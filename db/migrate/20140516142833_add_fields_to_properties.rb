class AddFieldsToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :default_label, :string
    add_column :properties, :default_value, :string
    remove_column :properties, :type
  end
end
