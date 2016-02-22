class CreateUserGroupsMembers < ActiveRecord::Migration
  def change
    create_table :user_groups_members do |t|
      t.integer :user_id
      t.integer :group_id

      t.timestamps
    end

    add_index :user_groups_members, :user_id
  end
end
