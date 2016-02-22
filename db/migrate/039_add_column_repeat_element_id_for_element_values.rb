class AddColumnRepeatElementIdForElementValues < ActiveRecord::Migration
  def change
    add_column :element_values, :repeat_element_id, :integer
  end
end
