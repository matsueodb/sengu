class CreateTemplateRecordSelectConditions < ActiveRecord::Migration
  def change
    create_table :template_record_select_conditions do |t|
      t.integer :template_id
      t.string :target_class
      t.text :condition
    end
  end
end
