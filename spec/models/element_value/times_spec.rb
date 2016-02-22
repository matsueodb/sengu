# == Schema Information
#
# Table name: element_value_date_contents
#
#  id         :integer          not null, primary key
#  value      :datetime
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::Times do
  let(:val){"2014-01-01 12:30:00"}
  let(:content){create(:element_value_times, value: val)}

  describe "method" do
    describe "#formatted_value" do
      subject{content.formatted_value}

      it "self['value']の値を、HH:MM形式の文字列で返すこと" do
        expect(subject).to eq("12:30")
      end
    end

    describe "#greater_than?" do
      it "引数で渡された値よりselfの値が大きい場合、trueが返ること" do
        expect(content.greater_than?("2014-01-01 12:29:00")).to be_true
      end

      it "引数で渡された値よりselfの値が小さい場合、falseが返ること" do
        expect(content.greater_than?("2014-01-01 12:31:00")).to be_false
      end
    end

    describe "#less_than?" do
      it "引数で渡された値よりselfの値が小さい場合、trueが返ること" do
        expect(content.less_than?("2014-01-01 12:31:00")).to be_true
      end

      it "引数で渡された値よりselfの値が大きい場合、falseが返ること" do
        expect(content.less_than?("2014-01-01 12:29:00")).to be_false
      end
    end

  end
end
