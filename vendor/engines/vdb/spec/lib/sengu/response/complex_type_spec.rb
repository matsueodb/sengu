require 'spec_helper'

describe Sengu::VDB::Response::ComplexType do
  describe "メソッド" do
    let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'complex_type.xml') }
    let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }
    let!(:namespaces) { doc.collect_namespaces }
    let(:domain) { 'domain' }
    let(:template) { create(:template) }

    before do
      create(:input_type_line)
      create(:input_type_multi_line)
      create(:input_type_dates)
      create(:input_type_google_location)
      # REF: spec/lib/sengu/response/element_item_spec.rb
      stub_const("Sengu::VDB::Response::ElementItem::LINE_TYPE", InputType.find_line)
      stub_const("Sengu::VDB::Response::ElementItem::VOCABULARY_TYPE", InputType.find_pulldown_vocabulary)
    end

    describe ".parse_with_doc" do
      before do
        doc.xpath('//xsd:complexType', namespaces).each do |comp|
          expect(Sengu::VDB::Response::ComplexType).to receive(:new).with(comp, doc, namespaces, domain)
        end
      end

      it "正しい引数でnewメソッドを呼び出していること" do
        Sengu::VDB::Response::ComplexType.parse_with_doc(doc, domain)
      end
    end

    describe "#initialize" do
      before do
        @node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(@node, doc, namespaces, domain)
      end

      it "対象ノードを正しく格納していること" do
        expect(@complex.node).to eq(@node)
      end

      it "項目名が正しくパースされいてること" do
        expect(@complex.name).to eq(doc.at('//xsd:complexType', namespaces)['name'])
      end

      it "説明を正しく格納しくパースしていること" do
        expect(@complex.description).to eq(doc.at('//xsd:documentation[@xml:lang="ja"]', namespaces).text)
      end

      it "elementsをパースして、アクセサにセットしていること" do
        elements = doc.xpath('//xsd:element[@ref]', namespaces).map{|el_node|
          Sengu::VDB::Response::ElementItem.new(el_node, doc, namespaces, domain, 1)
        }
        expect(@complex.elements.map(&:name)).to match_array(elements.map(&:name))
      end
    end

    describe "#to_elements" do
      before do
        node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(node, doc, namespaces, domain)
      end

      it "Elementインスタンスの配列を返すこと" do
        @complex.to_elements(template.id).each do |el|
          expect(el).to be_a_kind_of(Element)
        end
      end

      it "正しい数の配列が返ること" do
        expect(@complex.to_elements(template.id).count).to eq(
          doc.xpath('//xsd:element[@ref]', namespaces).count
        )
      end
    end

    describe "#save_element" do
      before do
        node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(node, doc, namespaces, domain)
      end

      it "エレメントの数分、データが増えていること" do
        expect{@complex.save_element(template.id)}.to change(Element, :count).by(
          doc.xpath('//xsd:element[@ref]', namespaces).count + 1
        )
      end

      context "保存時にエラーが発生した場合" do
        before do
          @name = doc.at('//xsd:element[@name]', namespaces).attr("name")
          @name = @complex.name
          create(:element, name: @name, template_id: template.id)
        end

        it "エレメントの数分、データが増えていないこと" do
          expect{@complex.save_element(template.id)}.to change(Element, :count).by(0)
        end

        it "falseが返ること" do
          expect(@complex.save_element(template.id)).to be_false
        end

        it ".error_messagesにエラーメッセージがセットされること" do
          msg = "【#{@name}】" + Element.human_attribute_name(:name) + I18n.t("errors.messages.taken")
          @complex.save_element(template.id)
          expect(@complex.error_messages).to match_array([msg])
        end
      end
    end

    describe "#parse_description" do
      before do
        node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(node, doc, namespaces, domain)
      end

      it "説明文を正しくパースしていること" do
        expect(@complex.send(:parse_description, namespaces)).to eq(doc.at('//xsd:documentation[@xml:lang="ja"]', namespaces).text)
      end
    end

    describe "parse_elements" do
      before do
        node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(node, doc, namespaces, domain)
      end

      it "Sengu::VDB::Response::ElementItemインスタンスを作成して、配列で返すこと" do
        elements = doc.xpath('//xsd:element[@ref]', namespaces).map{|el_node|
          Sengu::VDB::Response::ElementItem.new(el_node, doc, namespaces, domain, 1)
        }
        expect(@complex.send(:parse_elements, doc, namespaces, domain).map(&:name)).to match_array(elements.map(&:name))
      end
    end

    describe "element_nodes" do
      before do
        @node = doc.at('//xsd:complexType', namespaces)
        @complex = Sengu::VDB::Response::ComplexType.new(@node, doc, namespaces, domain)
      end

      context "拡張されていない場合" do
        it "ComplexType以下のノードが返ること" do
          nodes = @complex.send(:element_nodes, @node, doc, namespaces)
          expect(nodes).to match_array(@node.xpath('.//xsd:element', namespaces))
        end
      end

      context "拡張されている場合" do
        before do
          @doc = Nokogiri::XML(File.read(Vdb::Engine.root.join('spec', 'files', 'complex_type_extension.xml')))
          @node = doc.at('//xsd:complexType', namespaces)
          @complex = Sengu::VDB::Response::ComplexType.new(@node, doc, namespaces, domain)
        end

        it "ComplexType以下のノードが返ること" do
          nodes = @complex.send(:element_nodes, @node, doc, namespaces)
          ext_nodes = @node.xpath('.//xsd:element', namespaces)

          expect(nodes).to match_array(ext_nodes)
        end
      end
    end
  end
end
