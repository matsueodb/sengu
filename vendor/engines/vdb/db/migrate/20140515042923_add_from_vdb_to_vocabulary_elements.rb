class AddFromVdbToVocabularyElements < ActiveRecord::Migration
  def change
    add_column :vocabulary_elements, :from_vdb, :boolean, default: false
  end
end
