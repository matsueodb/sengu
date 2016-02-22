class CreateElementValueTextContents < ActiveRecord::Migration
  def change
    create_table :element_value_text_contents do |t|
      t.text :value
      t.string :type

      t.timestamps
    end
  end
end
