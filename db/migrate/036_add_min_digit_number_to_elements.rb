class AddMinDigitNumberToElements < ActiveRecord::Migration
  def change
    add_column :elements, :min_digit_number, :integer
  end
end
