class AddItemNumberToElementValues < ActiveRecord::Migration
  def change
    add_column :element_values, :item_number, :integer, default: 1
  end
end
