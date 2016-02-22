class AddDataTypeToElements < ActiveRecord::Migration
  def change
    add_column :elements, :data_type, :string
  end
end
