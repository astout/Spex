class AddColumnToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :default_visibility, :integer
  end
end
