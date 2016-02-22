class DropTableForVocabularyElementSupplements < ActiveRecord::Migration
  def up
    drop_table :vocabulary_element_supplements
  end
  
  def down
    create_table :vocabulary_element_supplements do |t|
      t.integer :element_id
      t.string :element_type
      t.integer :id_value
      t.string :text_value
      t.text :text_area_value

      t.timestamps
    end

    add_index :vocabulary_element_supplements, [:element_id, :element_type], name: 'v_e_supplements'
  end
end
