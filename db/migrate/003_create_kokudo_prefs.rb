class CreateKokudoPrefs < ActiveRecord::Migration
  def change
    create_table :kokudo_prefs do |t|
      t.string :name
    end
  end
end
