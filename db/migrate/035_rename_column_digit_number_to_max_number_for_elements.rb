class RenameColumnDigitNumberToMaxNumberForElements < ActiveRecord::Migration
  def self.up
    rename_column :elements, :digit_number, :max_digit_number
  end

  def self.down
    rename_column :elements, :max_digit_number, :digit_number
  end
end
