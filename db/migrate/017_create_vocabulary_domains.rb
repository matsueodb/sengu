class CreateVocabularyDomains < ActiveRecord::Migration
  def change
    create_table :vocabulary_domains do |t|
      t.string :name

      t.timestamps
    end
  end
end
