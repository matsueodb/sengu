class AddColumnMangerIdForSections < ActiveRecord::Migration
  def up
    add_column :sections, :manager_id, :integer
  end

  def down
    remove_column :sections, :manager_id
  end
end
