class CreateElementValueStringContents < ActiveRecord::Migration
  def change
    create_table :element_value_string_contents do |t|
      t.string :value
      t.string :type

      t.timestamps
    end
  end
end
