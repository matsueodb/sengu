class CreateVocabularyElements < ActiveRecord::Migration
  def change
    create_table :vocabulary_elements do |t|
      t.string :name
      t.text :description
      t.integer :domain_id

      t.timestamps
    end
  end
end
