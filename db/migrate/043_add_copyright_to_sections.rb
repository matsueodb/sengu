class AddCopyrightToSections < ActiveRecord::Migration
  def change
    add_column :sections, :copyright, :string
  end
end
