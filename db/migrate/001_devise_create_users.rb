class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :login,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      t.string :name
      t.string :remarks
      t.integer :authority
      t.timestamps
    end

    add_index :users, :login,                :unique => true
  end
end
