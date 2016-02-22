class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.integer :user_id
      t.integer :user_group_id
      t.integer :service_id
      t.integer :parent_id
      t.integer :status, default: Template.statuses[:publish]
    end

    add_index :templates, :user_id
    add_index :templates, :user_group_id
    add_index :templates, :service_id
    add_index :templates, :parent_id
  end
end
