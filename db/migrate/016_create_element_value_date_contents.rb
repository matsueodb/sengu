class CreateElementValueDateContents < ActiveRecord::Migration
  def change
    create_table :element_value_date_contents do |t|
      t.datetime :value
      t.string :type

      t.timestamps
    end
  end
end
