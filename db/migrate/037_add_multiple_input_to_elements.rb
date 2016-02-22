class AddMultipleInputToElements < ActiveRecord::Migration
  def change
    add_column :elements, :multiple_input, :boolean
  end
end
