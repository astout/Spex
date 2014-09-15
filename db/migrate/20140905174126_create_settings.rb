class CreateSettings < ActiveRecord::Migration
  def change
    remove_column :roles, :default, :boolean

    create_table :settings do |t|
      t.string  :name
      t.string  :value

      t.timestamps
    end
  end
end
