class CreateElementGroups < ActiveRecord::Migration
  def change
    create_table :element_groups do |t|
      t.integer :template_id
      t.string :name

      t.timestamps
    end

    add_index :element_groups, :template_id
  end
end
