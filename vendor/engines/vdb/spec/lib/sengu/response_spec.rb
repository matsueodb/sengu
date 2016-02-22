require 'spec_helper'

describe Sengu::VDB::Response do
  describe "メソッド" do
    before do
      create(:input_type_line)
      create(:input_type_multi_line)
      create(:input_type_dates)
      create(:input_type_google_location)
    end

    describe ".parse" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'complex_type.xml') }
      let(:domain) { 'core' }
      let(:getname) { '人型' }
      let(:code) { '200' }
      let(:success_response) {
        double('response', code: code, kind_of?: true, body: File.read(xml_file_path))
      }

      before do
        @response = Sengu::VDB::Response.parse(success_response, domain, getname)
      end

      it "getnameが正しく設定されていること" do
        expect(@response.getname).to eq(getname)
      end

      it "getnameが正しく設定されていること" do
        expect(@response.status).to eq(code)
      end

      context "レスポンスが成功の場合" do
        it "Sengu::VDB::Response::ComplexType.parse_with_docを呼び出していること" do
          expect(Sengu::VDB::Response::ComplexType).to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end

        it "Sengu::VDB::Response::ElementItem.parse_with_docを呼び出していること" do
          expect(Sengu::VDB::Response::ElementItem).to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end

        it "Sengu::VDB::Response::CodeList.parse_with_docを呼び出していること" do
          expect(Sengu::VDB::Response::CodeList).to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end
      end

      context "レスポンスが失敗の場合" do
        let(:success_response) {
          double('response', code: '202', kind_of?: false, body: File.read(xml_file_path))
        }

        it "Sengu::VDB::Response::ComplexType.parse_with_docを呼び出していないこと" do
          expect(Sengu::VDB::Response::ComplexType).not_to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end

        it "Sengu::VDB::Response::ElementItem.parse_with_docを呼び出していないこと" do
          expect(Sengu::VDB::Response::ElementItem).not_to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end

        it "Sengu::VDB::Response::CodeList.parse_with_docを呼び出していないこと" do
          expect(Sengu::VDB::Response::CodeList).not_to receive(:parse_with_doc)
          Sengu::VDB::Response.parse(success_response, domain, getname)
        end
      end

      context "処理中に例外が発生した場合" do
        it "Sengu::VDB::Response::ParseErrorを投げること" do
          Sengu::VDB::Response::ComplexType.stub(:parse_with_doc).and_raise(StandardError)
          expect{Sengu::VDB::Response.parse(success_response, domain, getname)}.to raise_error(Sengu::VDB::Response::ParseError)
        end
      end
    end

    describe ".domain_prefix" do
      let(:domain) { 'domain' }

      it "ドメインのプレフィックスが返ること" do
        expect(Sengu::VDB::Response.domain_prefix(domain)).to eq(Sengu::VDB::Response::DOMAIN_PREFIX[domain] + ':')
      end
    end

    describe "#initialize" do
      let(:status) { '204' }

      before do
        @response = Sengu::VDB::Response.new(status: status)
      end

      it "messageにstatusに対応するメッセージを入れていること" do
        expect(@response.message).to eq(I18n.t("sengu.vdb.response.messages.code_#{status}"))
      end
    end

    describe "#all_elements" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'complex_type.xml') }
      let(:success_response) {
        double('response', code: '200', kind_of?: true, body: File.read(xml_file_path))
      }

      before do
        @response = Sengu::VDB::Response.parse(success_response, 'core', '人型')
        @elements = @response.all_elements
        doc = Nokogiri::XML(File.read(xml_file_path))
        @names = doc.xpath('//xsd:element[@name]', doc.collect_namespaces).map{|el| el['name']}
      end

      it "全てのelement要素を返すこと" do
        expect(@elements.map(&:name)).to eq(@names)
      end
    end

    describe "#find_complex_with_getname" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'complex_type.xml') }
      let(:getname) { '輸送機関型' }
      let(:success_response) {
        double('response', code: '200', kind_of?: true, body: File.read(xml_file_path))
      }

      before do
        @response = Sengu::VDB::Response.parse(success_response, 'core', getname)
        @complex_type = @response.find_complex_with_getname
      end

      it "指定された名前の要素が返ること" do
        expect(@complex_type.name).to eq(getname)
      end
    end

    describe "#find_element_with_getname" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element.xml') }
      let(:getname) { '輸送機関_登録ナンバー' }
      let(:success_response) {
        double('response', code: '200', kind_of?: true, body: File.read(xml_file_path))
      }

      before do
        @response = Sengu::VDB::Response.parse(success_response, 'core', getname)
        @element = @response.find_element_with_getname
      end

      it "指定された名前の要素が返ること" do
        expect(@element.name).to eq(getname)
      end
    end

    describe "#find_code_list_with_getname" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'code_list.xml') }
      let(:getname) { '衣服種類1コード型' }
      let(:success_response) {
        double('response', code: '200', kind_of?: true, body: File.read(xml_file_path))
      }

      before do
        @response = Sengu::VDB::Response.parse(success_response, 'core', getname)
        @code_list = @response.find_code_list_with_getname
      end

      it "指定された名前の要素が返ること" do
        expect(@code_list.name).to eq(getname)
      end
    end

    describe "#find_code_list_with_getname" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'code_list.xml') }

      context "レスポンスが成功の場合" do
        let(:success_response) {
          double('response', code: '200', kind_of?: true, body: File.read(xml_file_path))
        }

        before do
          @response = Sengu::VDB::Response.parse(success_response, 'core', 'getname')
        end

        it "trueが返ること" do
          expect(@response.success?).to be_true
        end
      end

      context "レスポンスが失敗の場合" do
        let(:success_response) {
          double('response', code: '404', kind_of?: false, body: File.read(xml_file_path))
        }

        before do
          @response = Sengu::VDB::Response.parse(success_response, 'core', 'getname')
        end

        it "falseが返ること" do
          expect(@response.success?).to be_false
        end
      end
    end
  end
end
