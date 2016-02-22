# == Schema Information
#
# Table name: input_types
#
#  id                    :integer          not null, primary key
#  name                  :string(255)
#  label                 :string(255)
#  content_class_name    :string(255)
#  regular_expression_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#

require 'spec_helper'

describe InputType do
  let(:input_type){create(:input_type_line)}
  describe "scope" do
    before do
      InputType::TYPE_HUMAN_NAME.each do |name, label|
        create(:"input_type_#{name}")
      end
    end

    describe "locaitons" do
      subject{InputType.locations}
      it "input_typeが位置情報に関するものが返ること" do
        subject.each do |input_type|
          expect(input_type.name.to_sym.in?(InputType::LOCATION_NAMES)).to be_true
        end
      end
    end

    describe "vocabularies" do
      subject{InputType.vocabularies}

      it "input_typeが語彙に関する者が返ること" do
        subject.each do |input_type|
          expect(input_type.name.to_sym.in?(InputType::VOCABULARY_NAMES)).to be_true
        end
      end
    end

    describe "lines" do
      subject{InputType.lines}

      it "1行入力に関するものが返ること" do
        subject.each do |input_type|
          expect(input_type.name).to eq("line")
        end
      end
    end

    describe "referenced_templates" do
      subject{InputType.referenced_templates}

      it "input_typeがテンプレートを参照する型に関する者が返ること" do
        subject.each do |input_type|
          expect(input_type.name.to_sym.in?(InputType::REFERENCED_TEMPLATE_NAMES)).to be_true
        end
      end
    end
  end

  describe "method" do
    describe "#location?" do
      subject{input_type.location?}
      
      it "nameの値がLOCATION_NAMESに設定されている名前と一致する場合Trueが返ること" do
        input_type.stub(:name){InputType::LOCATION_NAMES.first}
        expect(subject).to be_true
      end

      it "nameの値がLOCATION_NAMESに設定されている名前と一致しない場合falseが返ること" do
        input_type.stub(:name){"line"}
        expect(subject).to be_false
      end
    end

    describe "#referenced_type?" do
      subject{input_type.referenced_type?}

      it "他のデータを参照する型の場合、trueが返ること" do
        input_type.name = "checkbox_template"
        expect(subject).to be_true
      end

      it "他のデータを参照する型ではない場合、falseが返ること" do
        input_type.name = "line"
        expect(subject).to be_false
      end
    end

    describe "#checkbox?" do
      subject{input_type.checkbox?}

      it "Checkboxの型の場合、trueが返ること" do
        input_type.name = "checkbox_template"
        expect(subject).to be_true
      end

      it "Checkboxの型以外の場合、falseが返ること" do
        input_type.name = "pulldown_template"
        expect(subject).to be_false
      end
    end
    
    describe "#pulldown?" do
      subject{input_type.pulldown?}

      it "Pulldownの型の場合、trueが返ること" do
        input_type.name = "pulldown_template"
        expect(subject).to be_true
      end

      it "Pulldownの型以外の場合、falseが返ること" do
        input_type.name = "checkbox_template"
        
        expect(subject).to be_false
      end
    end

    describe "#template?" do
      subject{input_type.pulldown?}

      it "Pulldownの型の場合、trueが返ること" do
        input_type.name = "pulldown_template"
        expect(subject).to be_true
      end

      it "Pulldownの型以外の場合、falseが返ること" do
        input_type.name = "checkbox_template"

        expect(subject).to be_false
      end
    end

    describe "#vocabulary?" do
      subject{input_type.vocabulary?}

      it "語彙に関係する型の場合、trueが返ること" do
        input_type.name = "pulldown_vocabulary"
        expect(subject).to be_true
      end

      it "語彙に関係する型以外の場合、falseが返ること" do
        input_type.name = "checkbox_template"

        expect(subject).to be_false
      end
    end

    
  end
end
