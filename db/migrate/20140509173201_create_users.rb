class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :login
      t.integer :role, default: 0
      t.boolean :admin, default: false

      t.timestamps
    end
  end
end
