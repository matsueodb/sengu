class CreateElementValueIdentifierContents < ActiveRecord::Migration
  def change
    create_table :element_value_identifier_contents do |t|
      t.integer :value
      t.string :type

      t.timestamps
    end
  end
end
