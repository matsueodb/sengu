class CreateInputTypes < ActiveRecord::Migration
  def change
    create_table :input_types do |t|
      t.string :name
      t.string :label
      t.string :content_class_name
      t.integer :regular_expression_id

      t.timestamps
    end

    add_index :input_types, :regular_expression_id
  end
end
