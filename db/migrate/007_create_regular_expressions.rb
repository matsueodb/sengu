class CreateRegularExpressions < ActiveRecord::Migration
  def change
    create_table :regular_expressions do |t|
      t.string :name
      t.string :format
      t.string :option
      t.boolean :editable, default: true
    end
  end
end
