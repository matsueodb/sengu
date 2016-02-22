class RemoveColumnManagerIdForSections < ActiveRecord::Migration
  def up
    remove_column :sections, :manager_id
  end

  def down
    add_column :sections, :manager_id, :integer
  end
end
