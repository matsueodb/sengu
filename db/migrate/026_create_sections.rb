class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :name
    end
  end
end
