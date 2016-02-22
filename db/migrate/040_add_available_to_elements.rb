class AddAvailableToElements < ActiveRecord::Migration
  def change
    add_column :elements, :available, :boolean, default: true
  end
end
