class AddColumnPublishForElements < ActiveRecord::Migration
  def change
    add_column :elements, :publish, :boolean, default: true
  end
end
