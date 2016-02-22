class CreateKokudoAddresses < ActiveRecord::Migration
  def change
    create_table :kokudo_addresses do |t|
      t.string :street
      t.integer :city_id
      t.float :latitude
      t.float :longitude
    end

    add_index :kokudo_addresses, :city_id
  end
end
