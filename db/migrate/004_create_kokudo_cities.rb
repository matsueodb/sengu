class CreateKokudoCities < ActiveRecord::Migration
  def change
    create_table :kokudo_cities do |t|
      t.string :name
      t.integer :pref_id
    end

    add_index :kokudo_cities, :pref_id
  end
end
