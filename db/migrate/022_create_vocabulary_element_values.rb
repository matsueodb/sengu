class CreateVocabularyElementValues < ActiveRecord::Migration
  def change
    create_table :vocabulary_element_values do |t|
      t.integer :element_id
      t.string :name

      t.timestamps
    end

    add_index :vocabulary_element_values, :element_id
  end
end
