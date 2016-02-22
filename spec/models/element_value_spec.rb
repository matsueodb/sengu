# == Schema Information
#
# Table name: element_values
#
#  id           :integer          not null, primary key
#  record_id    :integer
#  element_id   :integer
#  content_id   :integer
#  content_type :string(255)
#  kind         :integer
#  template_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe ElementValue do
  let(:element){build(:element)}
  let(:element_value){build(:element_value, element: element)}

  describe "association" do
    it{should belong_to(:template)}
    it{should belong_to(:template_record)}
    it{should belong_to(:element)}
    it{should belong_to(:content).dependent(:destroy)}
  end
  
  describe "scope" do
    describe "by_elements" do
      let(:e_id){create(:element_by_it_line).id}
      subject{ElementValue.by_elements(e_id)}

      before do
        3.times do |n|
          create(:element_value, kind: n, element_id: e_id)
          create(:element_value, kind: n)
        end
      end

      it "引数で渡したElementIDに関連するレコードが返ることでかつ、kindの昇順で取得されること" do
        subject.each do |s|
          expect(s.element_id).to eq(e_id)
        end
      end

      it "kindの昇順で返ること" do
        expect(subject).to eq(subject.sort_by(&:kind))
      end
    end
  end

  describe "validation" do
    let(:element){build(:element_by_it_line)}
    let(:element_value){build(:element_value, element: element)}
    it {element_value.should validate_presence_of(:item_number) }
    it {element_value.should ensure_inclusion_of(:content_type).in_array(ElementValue::ELEMENT_VALUE_CONTENT_CLASSES.map(&:name)) }
  end

  describe "callback" do
    describe "before_validation" do
      describe "#set_repeat_element_id" do
        let(:top_el){build(:element, id: 2, multiple_input: true)}
        let(:second_el){build(:element, id: 3, parent_id: 2)}

        before do
          element.parent_id = 3
          Element.import([top_el, second_el, element])
          @top_el_id = Element.find_by(multiple_input: true).id
          @element_value = element_value
        end

        subject do
          @element_value.save!
        end
        
        it "保存時にelement_idからmultiple_input==trueの最初の親エレメントのIDがrepeat_element_idにセットされること" do
          expect(@element_value.repeat_element_id).to be_nil
          subject
          expect(@element_value.reload.repeat_element_id).to eq(@top_el_id)
        end
      end
    end
  end

  describe "methods" do
    describe "#value" do
      subject{element_value.value}

      it "@valueがある場合、その値を返すこと" do
        element_value.value = "松江城"

        expect(subject).to eq("松江城")
      end

      it "@valueが無い場合、content.valueを返すこと" do
        element_value.stub_chain(:content, :value){"松江城"}

        expect(subject).to eq("松江城")
      end
    end

    describe "#formatted_value" do
      subject{element_value.formatted_value}

      it ".content.formatted_valueが呼ばれること" do
        element_value.stub_chain(:content, :formatted_value){"松江城"}
        expect(subject).to eq("松江城")
      end
    end

    describe "#editable_on?" do
      let(:template){create(:template)}
      let(:other_template){create(:template)}

      subject{element_value.editable_on?(template)}
      
      it "引数で渡したTemplateのIDとtemplate_idが等しい場合、trueが返ること" do
        element_value.stub(:template_id){template.id}

        expect(subject).to be_true
      end

      it "引数で渡したTemplateのIDとtemplate_idが等しくない場合、falseが返ること" do
        element_value.stub(:template_id){other_template.id}
        expect(subject).to be_false
      end
    end

    describe "#build_content" do
      let(:attr){{"value" => "松江城"}}
      let(:content_type){"ElementValue::Line"}
      before do
        element_value.stub(:content_type){content_type}
      end
      subject{element_value.build_content(attr)}

      it "self.contentにcontent_typeにセットされているクラスのインスタンスがセットされること" do
        con = ElementValue::Line.new(attr)
        ElementValue::Line.stub(:new){con}
        subject
        expect(element_value.content).to eq(con)
      end

      it "self.contentが既にセットされている場合、新たにセットされないこと" do
        con = ElementValue::MultiLine.new(attr)
        element_value.content = con
        subject
        expect(element_value.content).to eq(con)
      end
    end

    describe "#included_by_keyword?" do
      let(:keyword){"松江"}
      subject{element_value.included_by_keyword?(keyword)}

      it ".content.included_by_keyword?の結果が返ること" do
        con = ElementValue::Line.new
        element_value.stub(:content){con}
        con.stub(:included_by_keyword?){true}
        expect(subject).to be_true
      end
    end

    describe "private" do
      describe "#set_repeat_element_id" do
        let(:top_el){create(:element, multiple_input: true)}
        let(:second_el){create(:element, parent: top_el)}

        before do
          element.parent_id = second_el.id
        end

        subject{element_value.send(:set_repeat_element_id)}

        it "element_idからmultiple_input==trueの最初の親エレメントのIDがrepeat_element_idにセットされること" do
          expect{subject}.to change{element_value.repeat_element_id}.from(nil).to(top_el.id)
        end
      end
    end
  end
end
