require 'spec_helper'

describe Sengu::VDB::Response::ElementItem do
  describe "メソッド" do
    let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element.xml') }
    let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }
    let!(:namespaces) { doc.collect_namespaces }
    let(:domain) { 'core' }
    let(:template) { create(:template) }

    before do
      input_type_line = create(:input_type_line)
      input_type_pulldown_vocabulary = create(:input_type_pulldown_vocabulary)
      create(:input_type_multi_line)
      create(:input_type_dates)
      create(:input_type_google_location)
      # NOTE: rspec -P "spec/**/*_spec.rb" --default-path vendor/engines/vdb/ と実行すると落ちる
      # 理由は、先にSengu::VDB::Mappingが読み込まれ、そのときに定数が決定するが、その際にはinput_typesのレコードが１つもない
      # そのため、InputType.find_line.try(:id)がnilとなり、デフォルトのinput_type_idがnilとなり、エラーになる箇所が発生する
      # なので、以下のように定数をstub化する
      #
      # DEFAULT_MAPPINGは現在は使用していない　
      # stub_const("Sengu::VDB::Mapping::DEFAULT_MAPPING", { input_type_id: input_type_line.id })
      stub_const("Sengu::VDB::Response::ElementItem::LINE_TYPE", input_type_line)
      stub_const("Sengu::VDB::Response::ElementItem::VOCABULARY_TYPE", input_type_pulldown_vocabulary)
    end

    describe ".parse_with_doc" do
      before do
        doc.xpath('//xsd:element', namespaces).each do |el|
          expect(Sengu::VDB::Response::ElementItem).to receive(:new).with(el, doc, namespaces, domain, 1)
        end
      end

      it "正しい引数でnewメソッドを呼び出していること" do
        Sengu::VDB::Response::ElementItem.parse_with_doc(doc, domain)
      end
    end

    describe "#initialize" do
      before do
        node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain)
      end

      it "項目名が正しくパース出来ていること" do
        expect(@element_item.name).to eq(doc.at('//xsd:element', namespaces)['name'])
      end

      it "データタイプが正しくパース出来ていること" do
        expect(@element_item.data_type).to eq(doc.at('//xsd:element', namespaces)['type'])
      end

      it "説明を正しくパースしていること" do
        expect(@element_item.description).to eq(doc.at('//xsd:documentation[@xml:lang="ja"]', namespaces).text)
      end
    end

    describe "#to_element" do
      before do
        node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain)
        @element = @element_item.to_element(template.id)
      end

      it "Elementインスタンスをかえすこと" do
        expect(@element).to be_a_kind_of(Element)
      end

      it "nameを正しく設定していること" do
        expect(@element.name).to eq(@element_item.name)
      end

      it "descriptionを正しく設定していること" do
        expect(@element.description).to eq(@element_item.description)
      end

      it "template_idが正しく設定されていること" do
        expect(@element.template_id).to eq(template.id)
      end

      context "代替要素が存在する場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_children.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          node = doc.at('//xsd:element[@name]', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain)
          @element = @element_item.to_element(template.id)
        end

        it "子エレメントがセットされていること" do
          expect(@element.children.present?).to be_true
        end
      end
    end

    describe "#save_to_element" do
      before do
        node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain)
      end

      subject{@element_item.save_to_element(template.id)}

      context "エラーがない場合" do
        it "Elementレコードが追加されること" do
          expect{subject}.to change(Element, :count).by(1)
        end

        it "nameを正しく設定していること" do
          element = subject
          expect(element.name).to eq(@element_item.name)
        end

        it "descriptionを正しく設定していること" do
          element = subject
          expect(element.description).to eq(@element_item.description)
        end

        it "template_idが正しく設定されていること" do
          element = subject
          expect(element.template_id).to eq(template.id)
        end

        context "代替要素が存在する場合" do
          let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_children.xml') }
          let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

          before do
            node = doc.at('//xsd:element[@name]', namespaces)
            @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain, 1)
            @element = @element_item.save_to_element(template.id)
          end

          it "子エレメントがセットされていること" do
            expect(@element.children.present?).to be_true
          end
        end
      end

      context "エラーがある場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_children.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          @node = doc.at('//xsd:element[@name]', namespaces)
          Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1).save_to_element(template.id)

          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        subject{@element_item.save_to_element(template.id)}

        it "親エレメント、子エレメントのエラーが配列で返ること" do
          name = @node.at('//xsd:element[@name]', namespaces).attr("name")
          msg = "【#{name}】" + Element.human_attribute_name(:name) + I18n.t("errors.messages.taken")
          # 2回目の実行で重複エラーがでる。
          expect(subject).to eq([msg])
        end
      end
    end

    describe "#save_element" do
      before do
        @node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
      end

      it "エレメントの数分、データが増えていること" do
        expect{@element_item.save_element(template.id)}.to change(Element, :count).by(
          doc.xpath('//xsd:element[@name]', namespaces).count
        )
      end

      it "エラーがある場合、.error_messagesにエラーが設定されること" do
        name = @node.at('//xsd:element[@name]', namespaces).attr("name")
        input_type = create(:input_type_line)
        element = create(:element, name: name, template_id: template.id, input_type_id: input_type.id)
        msg = "【#{name}】" + Element.human_attribute_name(:name) + I18n.t("errors.messages.taken")
        @element_item.save_element(template.id)
        expect(@element_item.error_messages).to match_array([msg])
      end
    end

    describe "#all_elements" do
      before do
        node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain, 1)
      end

      it "全てのエレメントを配列で返すこと" do
        expect(@element_item.all_elements).to match_array([@element_item])
      end
    end

    describe "#detail_element_node" do
      context "参照先のあるノードの場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_ref.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          node = doc.at('//xsd:element[@ref]', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(node, doc, namespaces, domain, 1)
        end

        it "参照先を返すこと" do
          node = doc.at('//xsd:element[@name]', namespaces)
          expect(@element_item.send(:detail_element_node, doc, namespaces)).to eq(node)
        end
      end

      context "参照して無い場合" do
        before do
          @node = doc.at('//xsd:element', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        it "自分のノードを返すこと" do
          expect(@element_item.send(:detail_element_node, doc, namespaces)).to eq(@node)
        end
      end
    end

    describe "#parse_entry_name" do
      context "参照先がある場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_ref.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          @node = doc.at('//xsd:element[@ref]', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        it "自分のノードのref属性を返すこと" do
          expect(@element_item.send(:parse_entry_name, domain)).to eq(@node['ref'])
        end
      end

      context "参照してない場合" do
        before do
          @node = doc.at('//xsd:element', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        it "ドメインのprefixつきで自分のノードのname属性を返すこと" do
          prefix = "ic:"
          result = prefix + @node["name"]
          Sengu::VDB::Response.stub(:domain_prefix).with(domain){prefix}
          expect(@element_item.send(:parse_entry_name, domain)).to eq(result)
        end
      end
    end

    describe "#parse_description" do
      before do
        @node = doc.at('//xsd:element', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
      end

      it "descriptionが正しくパース出来ていること" do
        expect(@element_item.description).to eq(
          doc.at('//xsd:documentation[@xml:lang="ja"]', namespaces).text
        )
      end
    end

    describe "ref_node?" do
      context "参照先がある場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_ref.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          @node = doc.at('//xsd:element[@ref]', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        it "trueを返すこと" do
          expect(@element_item.send(:ref_node?)).to be_true
        end
      end

      context "参照先が無い場合" do
        before do
          @node = doc.at('//xsd:element', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain)
        end

        it "falseを返すこと" do
          expect(@element_item.send(:ref_node?)).to be_false
        end
      end
    end

    describe "#parse_children_element" do
      context "代替要素が存在する場合" do
        let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_children.xml') }
        let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

        before do
          @node = doc.at('//xsd:element[@name]', namespaces)
          @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        end

        it "子エレメントの配列が返ること" do
          child_els = @element_item.send(:parse_children_element, @node, doc, namespaces, domain)
          expect(child_els.count).to eq(
            doc.xpath('//xsd:element[@substitutionGroup]', namespaces).count
          )
        end
      end
    end

    describe "#element_new" do
      let(:xml_file_path) { Vdb::Engine.root.join('spec', 'files', 'element_children.xml') }
      let(:doc) { Nokogiri::XML(File.read(xml_file_path)) }

      before do
        @node = doc.at('//xsd:element[@name]', namespaces)
        @element_item = Sengu::VDB::Response::ElementItem.new(@node, doc, namespaces, domain, 1)
        @default_attr = {
          name: @element_item.name, entry_name: @element_item.entry_name,
          input_type_id: Sengu::VDB::Response::ElementItem::LINE_TYPE.id,
          description: @element_item.description, abstract: @element_item.abstract,
          original_data_type: (@element_item.data_type.present? ? @element_item.data_type.sub(/^.+:/, '') : ""),
          data_type: @element_item.data_type,
          domain_id: "core",
          source: nil
        }
      end

      it "@element_itemの情報をもとにElementモデルの新規インスタンスが返ること" do
        element = Element.new(@default_attr)
        Element.stub(:new).with(@default_attr){element}
        expect(@element_item.send(:element_new)).to eq(element)
      end

      it "引数attrに渡した値をマージしてElementモデルの新規インスタンスを生成すること" do
        element = Element.new(@default_attr.merge(template_id: 1))
        Element.stub(:new).with(@default_attr.merge(template_id: 1)){element}
        expect(@element_item.send(:element_new, {template_id: 1})).to eq(element)
      end
    end
  end
end
