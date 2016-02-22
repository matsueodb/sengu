class AddCopyrightToUsers < ActiveRecord::Migration
  def change
    add_column :users, :copyright, :string
  end
end
