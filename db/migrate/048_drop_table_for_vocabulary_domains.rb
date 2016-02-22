class DropTableForVocabularyDomains < ActiveRecord::Migration
  def up
    drop_table :vocabulary_domains 
  end
  
  def down
    create_table :vocabulary_domains do |t|
      t.string :name

      t.timestamps
    end
  end
end
