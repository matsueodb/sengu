class CreateVocabularyKeywords < ActiveRecord::Migration
  def change
    create_table :vocabulary_keywords do |t|
      t.string :name
      t.text :content
      t.integer :user_id
      t.integer :scope, default: Vocabulary::Keyword::SCOPES[:individual]

      t.timestamps
    end
  end
end
