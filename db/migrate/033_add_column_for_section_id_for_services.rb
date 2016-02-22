class AddColumnForSectionIdForServices < ActiveRecord::Migration
  def up
    add_column :services, :section_id, :integer
  end

  def down
    remove_column :services, :section_id
  end
end
