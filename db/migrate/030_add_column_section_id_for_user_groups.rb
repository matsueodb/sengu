class AddColumnSectionIdForUserGroups < ActiveRecord::Migration
  def up
    add_column :user_groups, :section_id, :integer
  end

  def down
    remove_column :user_groups, :section_id
  end
end
