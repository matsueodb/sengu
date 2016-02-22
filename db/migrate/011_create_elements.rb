class CreateElements < ActiveRecord::Migration
  def change
    create_table :elements do |t|
      t.string  :name
      t.string  :entry_name
      t.integer :template_id
      t.integer :group_id
      t.integer :regular_expression_id
      t.integer :parent_id
      t.integer :input_type_id
      t.integer :digit_number # 桁数
      t.string  :description
      t.string  :data_example
      t.boolean :required, default: false # 必須項目
      t.boolean :unique, default: false # ユニーク
      t.boolean :confirm_entry, default: false
      t.boolean :display, default: true # 一覧表示
      t.string :source_type # polymorphic
      t.integer :source_id  # polymorphic
      t.integer :display_number  # polymorphic

      t.timestamps
    end

    add_index :elements, :template_id
    add_index :elements, :regular_expression_id
    add_index :elements, :parent_id
    add_index :elements, :input_type_id
    add_index :elements, [:source_id, :source_type]
  end
end
