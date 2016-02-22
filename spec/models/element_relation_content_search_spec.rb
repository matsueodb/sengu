require 'spec_helper'

describe ElementRelationContentSearch do
  describe "methods" do
    describe "#initialize" do
      let(:element){create(:element_by_it_checkbox_template, source_id: 1, source_type: "Template")}
      let(:keyword){"松江"}

      let(:attr){{element_id: element.id, keyword: keyword}}
      
      subject{ElementRelationContentSearch.new(attr)}

      it "self.element_idからelementがセットされること" do
        expect(subject.element).to eq(element)
      end

      it "self.elementdからinput_typeがセットされること" do
        expect(subject.input_type).to eq(element.input_type)
      end
    end

    describe "#search" do

      context "element.reference_typeがTemplateの場合" do
        let(:template){create(:template)}
        let(:source){create(:template)}
        let(:se){create(:element_by_it_line, template_id: source.id)}
        let(:element){create(:element_by_it_checkbox_template, source: source, source_element_id: se.id, template_id: template.id)}
        let(:keyword){"松江"}
        let(:match_values){[
          create(:element_value, record_id: 1, element_id: se.id, content: build(:element_value_line, value: "松江城")),
          create(:element_value, record_id: 2, element_id: se.id, content: build(:element_value_line, value: "松江城下町")),
          create(:element_value, record_id: 3, element_id: se.id, content: build(:element_value_line, value: "松江体育館"), item_number: 1),
          create(:element_value, record_id: 3, element_id: se.id, content: build(:element_value_line, value: "鹿島体育館"), item_number: 2)
        ]}
        let(:unmatch_values){[
          create(:element_value, record_id: 4, element_id: se.id, content: build(:element_value_line, value: "県立美術館")),
          create(:element_value, record_id: 5, element_id: se.id, content: build(:element_value_line, value: "宍道湖"))
        ]}
        let(:values){match_values + unmatch_values}
        let(:attr){{element_id: element.id}}
        
        before do
          ElementRelationContentSearch.any_instance.stub(:element){element}
          element.stub(:reference_values){values}
        end

        subject{ElementRelationContentSearch.new(attr).search}

        it "キーワードがある場合、キーワードに一致する値が返ること" do
          ElementRelationContentSearch.any_instance.stub(:keyword){keyword}
          expect(subject).to eq(match_values.group_by(&:record_id))
        end
        
        it "キーワードがない場合、全てのレコードが返ること" do
          ElementRelationContentSearch.any_instance.stub(:keyword){""}
          expect(subject).to eq(values.group_by(&:record_id))
        end
      end

      context "element.reference_typeがVocabulary::Elementの場合" do
        let(:source){create(:vocabulary_element)}
        let(:element){create(:element_by_it_checkbox_vocabulary, source: source)}
        let(:keyword){"松江"}
        let(:match_values){[
          create(:vocabulary_element_value, element_id: source.id, name: "松江城"),
          create(:vocabulary_element_value, element_id: source.id, name: "松江城下町"),
        ]}
        let(:unmatch_values){[
          create(:vocabulary_element_value, element_id: source.id, name: "県立美術館"),
          create(:vocabulary_element_value, element_id: source.id, name: "宍道湖"),
        ]}
        let(:values){match_values + unmatch_values}
        let(:attr){{element_id: element.id}}
        before do
          values
        end

        subject{ElementRelationContentSearch.new(attr).search}

        it "キーワードがある場合、キーワードに一致する値が返ること" do
          ElementRelationContentSearch.any_instance.stub(:keyword){keyword}
          expect(subject).to eq(match_values)
        end

        it "キーワードがない場合、全てのレコードが返ること" do
          ElementRelationContentSearch.any_instance.stub(:keyword){""}
          expect(subject).to eq(values)
        end
      end
    end
  end
end
