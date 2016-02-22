class AddColumnSectionIdForUsers < ActiveRecord::Migration
  def up
    add_column :users, :section_id, :integer
  end

  def down
    remove_column :users, :section_id
  end
end
