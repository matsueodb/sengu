class RemoveColumnDomainIdForVocabularyElements < ActiveRecord::Migration
  def up
    remove_column :vocabulary_elements, :domain_id
  end
  
  def down
    add_column :vocabulary_elements, :domain_id, :integer
  end
end
