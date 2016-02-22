require 'spec_helper'

describe Sengu::Rdf::Builder do
  let(:template) { create(:template) }
  let(:namespaces) { Sengu::Rdf::Builder::XMLNS }

  describe "#initialize" do
    let(:template_records) { create_list(:template_record, 5, template: template) }
    let!(:elements) { create_list(:only_element, 5, template_id: template.id) }

    before do
      @builder = Sengu::Rdf::Builder.new(template, template_records)
    end

    it "@templateに正しい値を設定していること" do
      expect(@builder.instance_variable_get(:@template)).to eq(template)
    end

    it "@recordsに正しい値を設定していること" do
      expect(@builder.instance_variable_get(:@records)).to eq(template_records)
    end

    it "@elementsに正しい値を設定していること" do
      expect(@builder.instance_variable_get(:@elements)).to match_array(elements)
    end
  end

  describe "#to_rdf" do
    let(:builder) { Nokogiri::XML::Builder.new }

    subject{ @builder.to_rdf }

    before do
      allow_any_instance_of(Sengu::Rdf::Builder).to receive(:create_xml).and_return(builder)
      @builder = Sengu::Rdf::Builder.new(template)
    end

    it "xmlを返すこと" do
      expect(subject).to eq(Nokogiri::XML(builder.to_xml, nil, 'utf-8').to_xml.toutf8)
    end
  end

  describe "#create_xml" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    describe "メソッドの呼び出しの検証" do
      it "#set_tempalte_nameメソッドを呼び出していること" do
        expect_any_instance_of(Sengu::Rdf::Builder).to receive(:set_template_name)
        builder.send(:create_xml)
      end

      it "#set_elementsメソッドを呼び出していること" do
        expect_any_instance_of(Sengu::Rdf::Builder).to receive(:set_elements)
        builder.send(:create_xml)
      end

      it "#set_recordsメソッドを呼び出していること" do
        expect_any_instance_of(Sengu::Rdf::Builder).to receive(:set_records)
        builder.send(:create_xml)
      end

      it "#set_program_languageメソッドを呼び出していること" do
        expect_any_instance_of(Sengu::Rdf::Builder).to receive(:set_program_language)
        builder.send(:create_xml)
      end

      it "#set_licenseメソッドを呼び出していること" do
        expect_any_instance_of(Sengu::Rdf::Builder).to receive(:set_license)
        builder.send(:create_xml)
      end
    end

    describe "返り値の検証" do
      before do
        @xml = builder.send(:create_xml)
      end

      context "ルートノードの場合" do
        it "ネームスペースが正しく設定されていること" do
          expected_namespaces = Sengu::Rdf::Builder::XMLNS.except("xml:base")
          expect(@xml.parent.collect_namespaces).to eq(expected_namespaces)
        end

        it "ルートノードの名前が'RDF'であること" do
          root_node = @xml.doc.children.first
          expect(root_node.name).to eq('RDF')
        end

        it "ルートノードのプレフィックスが'rdf'であること" do
          root_node = @xml.doc.children.first
          expect(root_node.namespace.prefix).to eq('rdf')
        end

        it "ルートノードにxml:baseの属性が正しく設定されていること" do
          attr = @xml.doc.children.first.attributes.first.last
          expect("#{attr.namespace.prefix}:#{attr.name}").to eq("xml:base")
        end

        context "'rdf:Description'の場合" do
          before do
            @root_node = @xml.doc.children.first
          end

          it "ルートノードの下に'rdf:Descriptionというノードが作成されていること" do
            expect(@root_node.at('./rdf:Description', namespaces)).to be_true
          end

          it "'rdf:about属性が正しく設定されていること" do
            expected_path = Rails.application.routes.url_helpers.download_rdf_template_records_path(template)
            expect(@root_node.at('./rdf:Description', namespaces)['rdf:about']).to eq(expected_path)
          end
        end
      end
    end
  end

  describe "#set_template_name" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    before do
      Nokogiri::XML::Builder.new do |xml|
        xml.root(namespaces) do
          @xml = builder.send(:set_template_name, xml)
        end
      end
      @node = @xml.instance_variable_get(:@node)
    end

    it "'mlod:name'というノードを作成していること" do
      expect("#{@node.namespace.prefix}:#{@node.name}").to eq('mlod:name')
    end

    it "'mlod:name'に設定されている値が正しいこと" do
      expect(@node.text).to eq(template.name)
    end
  end

  describe "#set_program_language" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    before do
      Nokogiri::XML::Builder.new do |xml|
        xml.root(namespaces) do
          @xml = builder.send(:set_program_language, xml)
        end
      end
      @node = @xml.instance_variable_get(:@node)
    end

    it "'mlod:programingLanguage'というノードを作成していること" do
      expect("#{@node.namespace.prefix}:#{@node.name}").to eq('mlod:programingLanguage')
    end

    it "'mlod:programingLanguage'に設定されている値が正しいこと" do
      expect(@node.text).to eq(Sengu::Rdf::Builder::PROGRAM_NAME)
    end
  end

  describe "#set_elements" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    describe "メソッド呼び出しの検証" do
      it "#set_element_descriptionを呼び出していること" do
        expect(builder).to receive(:set_element_description)
        builder.send(:set_element_description)
      end
    end

    describe "返り値検証" do
      before do
        Nokogiri::XML::Builder.new do |xml|
          xml.root(namespaces) do
            @xml = builder.send(:set_elements, xml)
          end
        end
        @node = @xml.instance_variable_get(:@node)
      end

      it "'mlod:elementDefinition'というノードを作成していること" do
        expect("#{@node.namespace.prefix}:#{@node.name}").to eq('mlod:elementDefinition')
      end

      it "'mlod:elementDefinitionノードの一番目の子要素に'rdf:Description'ノードを作成していること" do
        node = @node.children.first
        expect("#{node.namespace.prefix}:#{node.name}").to eq('rdf:Description')
      end
    end
  end

  describe "#set_element_description" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    before do
      @root_element = create(:element)
      @children_els = create_list(:only_element, 5, template_id: @root_element.template_id, parent_id: @root_element.id, required: true, unique: true)
      b = Nokogiri::XML::Builder.new do |xml|
        xml.root(namespaces) do
          builder.send(:set_element_description, [@root_element], xml)
        end
      end
      @doc = b.doc
    end

    context "親項目の場合" do
      it "エレメントの表示部の最初に'mlod:elements'ノードが作成されていること" do
        expect(@doc.at('./root/mlod:elements', namespaces)).to be_true
      end

      it "'rdf:Description'の'rdf:about'正しいURLが設定されていること" do
        expected_path = Rails.application.routes.url_helpers.template_element_path(template, @root_element)
        expect(@doc.at('./root/mlod:elements/rdf:Description', namespaces)['rdf:about']).to eq(expected_path)
      end

      it "'mlod:elements'の'rdf:parseType'の値が正しいこと" do
        node = @doc.at('./root/mlod:elements', namespaces)
        expect(node['rdf:parseType']).to eq('Collection')
      end

      it "'mlod:name'に項目名が設定されていること" do
        node = @doc.at('./root/mlod:elements/rdf:Description/mlod:name', namespaces)
        expect(node.text).to eq(@root_element.name)
      end

      it "'mlod:entryName'にエントリーネームが設定されていること" do
        node = @doc.at('./root/mlod:elements/rdf:Description/mlod:entryName', namespaces)
        expect(node.text).to eq(@root_element.entry_name.to_s)
      end

      context "子項目が存在する場合" do
        before do
          @parent_node = @doc.at('./root/mlod:elements/rdf:Description')
        end

        it "'mlod:elements'が作成されること" do
          expect(@parent_node.at('./mlod:elements', namespaces)).to be_true
        end

        it "'mlod:elements'の'rdf:parseType'の値が正しいこと" do
          node = @parent_node.at('./mlod:elements', namespaces)
          expect(node['rdf:parseType']).to eq('Collection')
        end

        it "'rdf:Description'の'rdf:about'正しいURLが設定されていること" do
          @parent_node.at('./mlod:elements', namespaces).xpath('./rdf:Description', namespaces).each_with_index do |child_node, idx|
            expected_path = Rails.application.routes.url_helpers.template_element_path(template, @children_els[idx])
            expect(child_node['rdf:about']).to eq(expected_path)
          end
        end

        it "'mlod:name'に子項目名が設定されていること" do
          @parent_node.at('./mlod:elements', namespaces).xpath('./rdf:Description', namespaces).each_with_index do |child_node, idx|
            expect(child_node.at('./mlod:name').text).to eq(@children_els[idx].name)
          end
        end

        it "'mlod:entryName'にエントリー名が設定されていること" do
          @parent_node.at('./mlod:elements', namespaces).xpath('./rdf:Description', namespaces).each_with_index do |child_node, idx|
            expect(child_node.at('./mlod:entryName').text).to eq(@children_els[idx].entry_name.to_s)
          end
        end

        it "'mlod:inputType'に入力フィールド名が設定されていること" do
          @parent_node.at('./mlod:elements', namespaces).xpath('./rdf:Description', namespaces).each_with_index do |child_node, idx|
            expect(child_node.at('./mlod:inputType').text).to eq(@children_els[idx].input_type_label)
          end
        end

        it "'mlod:description'に説明・備考が設定されていること" do
          @parent_node.at('./mlod:elements', namespaces).xpath('./rdf:Description', namespaces).each_with_index do |child_node, idx|
            expect(child_node.at('./mlod:description').text).to eq(@children_els[idx].description.to_s)
          end
        end
      end
    end
  end

  describe "#set_records" do
    let(:builder) { Sengu::Rdf::Builder.new(template, template.template_records) }
    let(:input_type) { element.input_type }

    describe "共通部分の検証" do
      before do
        @record = create(:template_record, template_id: template.id)
        b = Nokogiri::XML::Builder.new do |xml|
          xml.root(namespaces) do
            builder.send(:set_records, xml)
          end
        end
        @doc = b.doc
      end

      it "'mlod:data'ノードを作成していること" do
        expect(@doc.at('./root/mlod:data', namespaces)).to be_true
      end

      it "'rdf:Descriptionノードの'rdf:about'属性に正しいURLを設定していること" do
        expected_path = Rails.application.routes.url_helpers.template_records_path(template)
        expect(@doc.at('./root/mlod:data/rdf:Description', namespaces)['rdf:about']).to eq(expected_path)
      end

      it "'mlod:templateRecords'rdf:parseType'属性に正しい値を設定していること" do
        expect(@doc.at('./root/mlod:data/rdf:Description/mlod:templateRecords', namespaces)['rdf:parseType']).to eq("Collection")
      end

      it "'rdf:Description'rdf:about'属性に正しいURLを設定していること" do
        expected_path = Rails.application.routes.url_helpers.template_record_path(template, @record)
        expect(@doc.at('./root/mlod:data/rdf:Description/mlod:templateRecords/rdf:Description', namespaces)['rdf:about']).to eq(expected_path)
      end
    end

    describe "入力データ部の検証" do
      context "一行入力のデータの場合" do
        let(:string_value) { '美術館' }
        let(:element) { create(:element_by_it_line, template_id: template.id) }

        before do
          t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type)
          value.build_content(value: string_value, type: input_type.content_class_name)
          t_r.save
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(string_value)
        end
      end

      context "複数行入力のデータの場合" do
        let(:multi_line_value) { "美術館です。\n美術品の展示が行われています" }
        let(:element) { create(:element_by_it_multi_line, template_id: template.id) }

        before do
          t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type)
          value.build_content(value: multi_line_value, type: input_type.content_class_name)
          t_r.save
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(multi_line_value)
        end
      end

      context "テンプレート参照の複数選択のデータの場合" do
        let(:source_template) { create(:template) }
        let!(:select_records) { create_list(:tr_with_all_values, 2, template_id: source_template.id) }
        let(:source_element) { source_template.elements.find_by(input_type_id: InputType.find_line.id) }
        let(:element) { create(:element_by_it_checkbox_template, template_id: template.id, source: source_template, source_element_id: source_element.id) }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          select_records.each do |record|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: record.id)
            value.build_content(value: record.id, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.xpath('./mlod:value').map(&:text)).to eq(element.code_list_values)
        end
      end

      context "テンプレート参照の単一選択のデータの場合" do
        let(:source_template) { create(:template) }
        let!(:select_records) { create_list(:tr_with_all_values, 1, template_id: source_template.id) }
        let(:source_element) { source_template.elements.first }
        let(:element) { create(:element_by_it_pulldown_template, template_id: template.id, source: source_template, source_element_id: source_element.id) }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          select_records.each do |record|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: record.id)
            value.build_content(value: record.id, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(@t_r.values.map(&:formatted_value).join(','))
        end
      end

      context "語彙環境の複数選択のデータの場合" do
        let(:vocabulary_element) { create(:vocabulary_element_with_values) }
        let(:select_vocabularies) { vocabulary_element.values }
        let(:element) { create(:element_by_it_checkbox_vocabulary, template_id: template.id, source: vocabulary_element) }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          select_vocabularies.each do |vocabulary|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: vocabulary.id)
            value.build_content(value: vocabulary.id, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.xpath('./mlod:value').map(&:text)).to match_array(select_vocabularies.pluck(:name))
        end
      end

      context "語彙環境の単一選択のデータの場合" do
        let(:vocabulary_element) { create(:vocabulary_element_with_values) }
        let(:select_vocabulary) { vocabulary_element.values.first }
        let(:element) { create(:element_by_it_pulldown_vocabulary, template_id: template.id, source: vocabulary_element) }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: select_vocabulary.id)
          value.build_content(value: select_vocabulary.id, type: input_type.content_class_name)
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(select_vocabulary.name)
        end
      end

      context "位置情報(国土地理院)の場合" do
        let(:element) { create(:element_by_it_kokudo_location, template_id: template.id) }
        let(:kinds) { [1, 2] }
        let(:location_value) { 1234.567 }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          kinds.each do |kind|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: kind)
            value.build_content(value: location_value, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value/geo:Point/geo:lat'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:lat').text).to eq(location_value.to_s)
        end

        it "'mlod:value/geo:Point/geo:long'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:long').text).to eq(location_value.to_s)
        end
     end

      context "位置情報(OpenStreetMap)の場合" do
        let(:element) { create(:element_by_it_osm_location, template_id: template.id) }
        let(:kinds) { [1, 2] }
        let(:location_value) { 1234.567 }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          kinds.each do |kind|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: kind)
            value.build_content(value: location_value, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value/geo:Point/geo:lat'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:lat').text).to eq(location_value.to_s)
        end

        it "'mlod:value/geo:Point/geo:long'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:long').text).to eq(location_value.to_s)
        end
      end

      context "位置情報(Google Map)の場合" do
        let(:element) { create(:element_by_it_google_location, template_id: template.id) }
        let(:kinds) { [1, 2] }
        let(:location_value) { 1234.567 }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          kinds.each do |kind|
            value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: kind)
            value.build_content(value: location_value, type: input_type.content_class_name)
          end
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value/geo:Point/geo:lat'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:lat').text).to eq(location_value.to_s)
        end

        it "'mlod:value/geo:Point/geo:long'に正しい値が設定されていること" do
          expect(@value_node.at('./mlod:value/geo:Point/geo:long').text).to eq(location_value.to_s)
        end
      end

      context "日付データの場合" do
        let(:element) { create(:element_by_it_dates, template_id: template.id) }
        let(:date_value) { Date.today }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type)
          value.build_content(value: date_value, type: input_type.content_class_name)
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(date_value.to_s)
        end
      end

      context "時間データの場合" do
        let(:element) { create(:element_by_it_times, template_id: template.id) }
        let(:time_value) { '10:00' }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type)
          value.build_content(value: time_value, type: input_type.content_class_name)
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value'ノードに文字列が値として設定されていること" do
          expect(@value_node.at('./mlod:value').text).to eq(time_value)
        end
      end

      context "ファイルデータの場合" do
        let(:element) { create(:element_by_it_upload_file, template_id: template.id) }
        let(:file_name) { 'test.txt' }
        let(:label) { 'label' }
        let(:file_value) { ActionDispatch::Http::UploadedFile.new(filename: file_name,
                                                                  type: 'text/plain',
                                                                  tempfile: File.open(Rails.root.join('spec', 'files', 'test.txt'))) }

        before do
          @t_r = build(:template_record, template_id: template.id)
          content_type = input_type.content_class_name.constantize.superclass.to_s
          value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: ElementValue::FILE_KIND)
          value.build_content(upload_file: file_value, type: input_type.content_class_name)

          label_value =  @t_r.values.build(element_id: element.id, template_id: template.id, content_type: content_type, kind: ElementValue::LABEL_KIND)
          label_value.build_content(value: label, type: input_type.content_class_name)
          @t_r.save!
          b = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_elements, xml)
              builder.send(:set_records, xml)
            end
          end
          @value_node = b.doc.at('.//rdf:Description/mlod:elementValues/mlod:elementValue')
        end

        it "'mlod:name'ノードに項目名が値として設定されていること" do
          expect(@value_node.at('./mlod:name').text).to eq(element.name)
        end

        it "'mlod:value/mlod:name'ノードにファイル名が値として設定されていること" do
          expect(@value_node.at('./mlod:value/mlod:name').text).to eq(file_name)
        end

        it "'mlod:value/mlod:label'ノードにラベル名が値として設定されていること" do
          expect(@value_node.at('./mlod:value/mlod:label').text).to eq(label)
        end

        it "'mlod:value/mlod:binary'ノードにファイルの値がBase64でエンコードされて設定されていること" do
          expect(@value_node.at('./mlod:value/mlod:binary').text).to eq(Base64.encode64(File.read(file_value.path)))
        end
      end
    end
  end

  describe "#set_rights" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    context "データ作成者の所属にコピーライトが設定してある場合" do
      let(:section_copyright) { 'section copyright' }
      let(:section) { create(:section, copyright: section_copyright) }

      context "ユーザにもコピーライトが設定してある場合" do
        let(:user_copyright) { 'user_copyright' }
        let(:user) { create(:super_user, copyright: user_copyright, section_id: section.id) }

        before do
          @xml = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_rights, xml, create(:template_record, user_id: user.id))
            end
          end
        end

        it "'dc:rights/dc:Agent/dc:title'に所属のコピーライトが優先して設定してあること" do
          expect(@xml.doc.at('./root/dc:rights/dc:Agent/dc:title', namespaces).text).to eq(section_copyright)
        end
      end

      context "ユーザにはコピーライトが設定されていない場合" do
        let(:user) { create(:super_user, section_id: section.id) }

        before do
          @xml = Nokogiri::XML::Builder.new do |xml|
            xml.root(namespaces) do
              builder.send(:set_rights, xml, create(:template_record, user_id: user.id))
            end
          end
        end

        it "'dc:rights/dc:Agent/dc:title'に所属のコピーライトが設定してあること" do
          expect(@xml.doc.at('./root/dc:rights/dc:Agent/dc:title', namespaces).text).to eq(section_copyright)
        end
      end
    end

    context "ユーザのみにコピーライトが設定されてある場合" do
      let(:section) { create(:section) }
      let(:user_copyright) { 'user_copyright' }
      let(:user) { create(:super_user, copyright: user_copyright, section_id: section.id) }

      before do
        @xml = Nokogiri::XML::Builder.new do |xml|
          xml.root(namespaces) do
            builder.send(:set_rights, xml, create(:template_record, user_id: user.id))
          end
        end
      end

      it "'dc:rights/dc:Agent/dc:title'にユーザのコピーライトが優先して設定してあること" do
        expect(@xml.doc.at('./root/dc:rights/dc:Agent/dc:title', namespaces).text).to eq(user_copyright)
      end
    end
  end

  describe "#set_license" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }

    before do
      Nokogiri::XML::Builder.new do |xml|
        xml.root(namespaces) do
          @xml = builder.send(:set_license, xml)
        end
      end
      @node = @xml.instance_variable_get(:@node)
    end

    it "'License'というノードを作成していること" do
      expect(@node.name).to eq('License')
    end

    it "'Lisence'というノードのrdf:about属性に正しいURLを設定していること" do
      expect(@node['rdf:about']).to eq(Sengu::Rdf::Builder::CREATIVECOMMONS_URL)
    end
  end

  describe "#set_last_modified" do
    let(:builder) { Sengu::Rdf::Builder.new(template) }
    let(:last_modified) { "2014-06-14" }
    let(:template_record) { create(:template_record, template: template, updated_at: last_modified) }


    before do
      @xml = Nokogiri::XML::Builder.new do |xml|
        xml.root(namespaces) do
          builder.send(:set_last_modified, xml, template_record)
        end
      end
    end

    it "'dcterms:modified'に最終更新日が設定されていること" do
      expect(@xml.doc.at('./root/dcterms:modified', namespaces).text).to eq(last_modified)
    end
  end
end
