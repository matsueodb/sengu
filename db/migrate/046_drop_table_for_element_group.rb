class DropTableForElementGroup < ActiveRecord::Migration
  def up
    drop_table :element_groups
  end

  def down
    create_table :element_groups do |t|
      t.integer :template_id
      t.string :name

      t.timestamps
    end

    add_index :element_groups, :template_id
  end
end
