class CreateElementValues < ActiveRecord::Migration
  def change
    create_table :element_values do |t|
      t.integer :record_id
      t.integer :element_id
      t.integer :content_id
      t.string :content_type
      t.integer :kind # 種類
      t.integer :template_id

      t.timestamps
    end

    add_index :element_values, :element_id
    add_index :element_values, [:content_id, :content_type]
    add_index :element_values, :template_id
  end
end
