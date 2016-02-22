class AddColumnDisplayNumberForTemplates < ActiveRecord::Migration
  def change
    add_column :templates, :display_number, :integer
  end
end
