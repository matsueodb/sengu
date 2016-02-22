class CreateElementKeywords < ActiveRecord::Migration
  def change
    create_table :element_keywords do |t|
      t.integer :element_id
      t.integer :user_id
      t.text :content
      t.integer :scope, default: Vocabulary::Keyword::SCOPES[Vocabulary::Keyword::INDIVIDUAL]

      t.timestamps
    end
  end
end
