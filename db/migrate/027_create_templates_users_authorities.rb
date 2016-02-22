class CreateTemplatesUsersAuthorities < ActiveRecord::Migration
  def change
    create_table :templates_users_authorities do |t|
      t.integer :template_id
      t.integer :user_id
      t.integer :authority, default: 0
    end
  end
end
