# == Schema Information
#
# Table name: element_value_string_contents
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::Line do
  let(:content){create(:element_value_line)}
  
  describe "methods" do

    before do
      content.update!(value: "50")
    end
    
    describe "#greater_than?" do
      it "引数で渡された値よりselfの値が大きい場合、trueが返ること" do
        expect(content.greater_than?("40")).to be_true
      end

      it "引数で渡された値よりselfの値が小さい場合、falseが返ること" do
        expect(content.greater_than?("60")).to be_false
      end
    end

    describe "#less_than?" do
      it "引数で渡された値よりselfの値が小さい場合、trueが返ること" do
        expect(content.less_than?("60")).to be_true
      end

      it "引数で渡された値よりselfの値が大きい場合、falseが返ること" do
        expect(content.less_than?("40")).to be_false
      end
    end
  end
end
