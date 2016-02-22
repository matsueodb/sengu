class DropTableForElementKeywords < ActiveRecord::Migration
  def up
    drop_table :element_keywords
  end
  
  def down
    create_table :element_keywords do |t|
      t.integer :element_id
      t.integer :user_id
      t.text :content
      t.integer :scope, default: Vocabulary::Keyword::SCOPES[Vocabulary::Keyword::INDIVIDUAL]

      t.timestamps
    end
  end
end
