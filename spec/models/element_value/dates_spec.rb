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

describe ElementValue::Dates do
  let(:val){"2014-01-01 00:00:00"}
  let(:content){create(:element_value_dates)}

  describe "method" do
    
    before do
      content.update(value: val)
    end
    
    describe "#value" do
      subject{content.value}

      it "self['value']の値を、YYYY-MM-DD形式の文字列で返すこと" do
        expect(subject).to eq("2014-01-01")
      end
    end

    describe "#greater_than?" do
      it "引数で渡された値よりselfの値が大きい場合、trueが返ること" do
        expect(content.greater_than?("2013-12-31")).to be_true
      end

      it "引数で渡された値よりselfの値が小さい場合、falseが返ること" do
        expect(content.greater_than?("2014-01-02")).to be_false
      end
    end

    describe "#less_than?" do
      it "引数で渡された値よりselfの値が小さい場合、trueが返ること" do
        expect(content.less_than?("2014-01-02")).to be_true
      end

      it "引数で渡された値よりselfの値が大きい場合、falseが返ること" do
        expect(content.less_than?("2013-12-31")).to be_false
      end
    end

    describe "private" do
      describe "set_value" do
        before do
          content.update(value: nil)
        end
        subject{content.send(:set_value)}
        it "self.valueの値がself['value']にセットされること" do
          content.stub(:value){val}
          expect{subject}.to change{content["value"]}.from(nil).to(content.value)
        end
      end
    end
  end
end
