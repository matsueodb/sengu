require 'spec_helper'

describe Sengu::VDB::Response::ComplexType do
  describe "メソッド" do
    let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'code_list.xml') }
    let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }
    let!(:namespaces) { doc.collect_namespaces }
    let(:domain) { 'domain' }

    describe ".parse_with_doc" do
      before do
        doc.xpath('//xsd:complexType', namespaces).each do |comp|
          values = Sengu::VDB::Response::CodeList.parse_values(doc, comp, namespaces)
          expect(Sengu::VDB::Response::CodeList).to receive(:new).with(values, comp, namespaces)
        end
      end

      it "正しい引数でnewメソッドを呼び出していること" do
        Sengu::VDB::Response::CodeList.parse_with_doc(doc, domain)
      end
    end

    describe "#initialize" do
      before do
        @node = doc.at('//xsd:complexType', namespaces)
        @code_list = Sengu::VDB::Response::CodeList.new([], @node, namespaces)
      end

      it "@nodeを正しく設定していること" do
        expect(@code_list.node).to eq(@node)
      end

      it "@nameを正しく設定していること" do
        expect(@code_list.name).to eq(@node['name'])
      end
    end

    describe "#to_vocabulary_element" do
      before do
        @node = doc.at('//xsd:complexType', namespaces)
        values = Sengu::VDB::Response::CodeList.parse_values(doc, @node, namespaces)
        @code_list = Sengu::VDB::Response::CodeList.new(values, @node, namespaces)
        @vocabulary_element = @code_list.to_vocabulary_element
      end

      it "nameが正しく設定されていること" do
        expect(@vocabulary_element.name).to eq(@code_list.name)
      end

      it "Vocabulary::ElementValueがビルドされていること" do
        values = @node.at('.//xsd:documentation[@xml:lang="ja"]', namespaces).text.strip.split('、').map{|c| c.sub(/^.+：/, '')}
        expect(@vocabulary_element.values.map(&:name)).to match_array(values)
      end
    end

    describe "#save_vocabulary_element" do
      before do
        node = doc.at('//xsd:complexType', namespaces)
        values = Sengu::VDB::Response::CodeList.parse_values(doc, node, namespaces)
        @code_list = Sengu::VDB::Response::CodeList.new(values, node, namespaces)
      end

      it "エレメントの数分、データが増えていること" do
        expect{@code_list.save_vocabulary_element}.to change(Vocabulary::Element, :count).by(
          doc.xpath('//xsd:complexType', namespaces).count
        )
      end
    end

    describe ".parse_values" do
      before do
        @node = doc.at('//xsd:complexType', namespaces)
        @code_list = Sengu::VDB::Response::CodeList.parse_values(doc, @node, namespaces)
      end

      it "値のリスト配列が返ること" do
        expect(@code_list).to match_array(
          @node.at('.//xsd:documentation[@xml:lang="ja"]', namespaces).text.strip.split('、').map{|c| c.sub(/^.+：/, '')}
        )
      end
    end
  end
end
