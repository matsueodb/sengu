class AddColumnCategoryToVocabularyKeywords < ActiveRecord::Migration
  def change
    add_column :vocabulary_keywords, :category, :text
  end
end
