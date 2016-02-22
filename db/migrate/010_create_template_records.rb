class CreateTemplateRecords < ActiveRecord::Migration
  def change
    create_table :template_records do |t|
      t.integer :template_id
      t.integer :user_id

      t.timestamps
    end

    add_index :template_records, :template_id
    add_index :template_records, :user_id
  end
end
