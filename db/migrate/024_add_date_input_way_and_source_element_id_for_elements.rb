class AddDateInputWayAndSourceElementIdForElements < ActiveRecord::Migration
  def up
    add_column :elements, :data_input_way, :integer, default: 0
    add_column :elements, :source_element_id, :integer
  end

  def down
    remove_column :elements, :data_input_way
    remove_column :elements, :source_element_id
  end
end
