# == Schema Information
#
# Table name: regular_expressions
#
#  id       :integer          not null, primary key
#  name     :string(255)
#  format   :string(255)
#  option   :string(255)
#  editable :boolean          default(TRUE)
#

require 'spec_helper'

describe RegularExpression do
  let(:name){"半角英語"}
  let(:format){"^[a-zA-Z]+$"}
  let(:option){"i"}
  let(:re){create(:regular_expression, name: name, format: format, option: option)}

  let(:user){create(:editor_user)}
  let(:template){create(:template, user_id: user.id)}

  describe "validation" do
    it {should validate_presence_of :name}
    it {should ensure_length_of(:name).is_at_most(255) }
    it { should validate_uniqueness_of(:name)}
    it {should validate_presence_of :format}
    it {should ensure_length_of(:format).is_at_most(255) }
    it {should ensure_length_of(:option).is_at_most(3) }
  end

  describe "association" do
    it {should have_many(:elements)}
  end

  describe "method" do
    describe ".formatted" do
      it "'/' + format + '/' + optionが返ること" do
        expect(re.formatted).to eq("/#{format}/" + option)
      end
    end

    describe ".to_regexp" do
      let(:formatted){"^[a-zA-Z]+$"}
      let(:opv){7}
      it ".formattedで返る値をもとにRegexp.newをしたものが返ること" do
        re.stub(:formatted){formatted}
        re.stub(:option_value){opv}
        expect(re.to_regexp).to eq(Regexp.new(formatted, opv))
      end
    end

    describe ".destroyable?" do
      subject{re.destroyable?}
      it "editable==trueの場合trueが返ること" do
        re.stub(:editable?){true}
        expect(subject).to be_true
      end

      it "editable==falseの場合falseが返ること" do
        re.stub(:editable?){false}
        expect(subject).to be_false
      end
    end
  end
end
