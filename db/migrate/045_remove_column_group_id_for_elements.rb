class RemoveColumnGroupIdForElements < ActiveRecord::Migration
  def up
    remove_column :elements, :group_id
  end

  def down
    add_column :elements, :group_id, :integer
  end
end
