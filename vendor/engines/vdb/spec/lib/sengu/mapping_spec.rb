require 'spec_helper'

describe Sengu::VDB::Mapping do
  let(:data_type) {YAML.load_file(Vdb::Engine.root.join('config', 'mapping', 'data_type', "#{Rails.env}.yml"))}
  let(:entry_name) {YAML.load_file(Vdb::Engine.root.join('config', 'mapping', 'entry_name', "#{Rails.env}.yml"))}
  let(:input_types) {YAML.load(IO.read(Rails.root.join('db', 'fixtures', "003_input_types.yml")))}
  let(:regular_expressions) {YAML.load(IO.read(Rails.root.join('db', 'fixtures', "002_regular_expression.yml")))}
  let(:code_lists) {YAML.load(IO.read(Vdb::Engine.root.join('db', 'fixtures', 'vocabulary', "006_elements.yml")))}

  describe "メソッド" do
    describe ".mapping" do
      let(:code_list_name) { "codes:面積単位コード型" }

      before do
        Vocabulary::Element.create(code_lists["menseki_tani"])
        @element = Element.new(name: "面積単位", data_type: code_list_name)
        Sengu::VDB::Mapping.mapping(@element)
      end

      it "source_typeが正しくマッピングされていること" do
        expect(@element.source_type).to eq("Vocabulary::Element")
      end

      it "source_idが正しくマッピングされていること" do
        expect(@element.source_id).to eq(code_lists["menseki_tani"]["id"])
      end
    end

    describe ".find_by_data_type" do
      before do
        Vocabulary::Element.create(code_lists["menseki_tani"])
        @attr = Sengu::VDB::Mapping.send(:find_by_data_type, "codes:面積単位コード型")
      end

      it "正しい情報を取得していること" do
        expect(@attr).to eq(:input_type_id=>6,  :source_id=>1,  :source_type=>"Vocabulary::Element")
      end
    end

    describe ".find_by_entry_name" do
      before do
        @attr = Sengu::VDB::Mapping.send(:find_by_entry_name, "ic:構造化住所_郵便番号")
      end

      it "正しい情報を取得していること" do
        expect(@attr).to eq("max_digit_number"=>7,  "required"=>true,  :input_type_id=>1,  :regular_expression_id=>4)
      end
    end

    describe ".set_value_by_label" do
      let(:input_type_name) { "it_line" }
      let(:regxp_name) { "location" }
      let(:code_list_name) { "menseki_tani" }

      before do
        Vocabulary::Element.create(code_lists[code_list_name])
        @attr = {"input_type" => input_type_name, "regular_expression" => regxp_name}
        Sengu::VDB::Mapping.send(:set_value_by_label, @attr)
      end

      it "正しいinput_type_idをハッシュにマージしていること" do
        expect(@attr[:input_type_id]).to eq(input_types[input_type_name]["id"])
      end

      it "正しいregular_expression_idをハッシュにマージしていること" do
        expect(@attr[:regular_expression_id]).to eq(regular_expressions[regxp_name]["id"])
      end
    end

    describe ".set_input_type_id" do
      let(:input_type_name) { "it_line" }
      before do
        @attr = {"input_type" => input_type_name }
      end

      it "正しいinput_type_idをハッシュにマージしていること" do
        Sengu::VDB::Mapping.send(:set_input_type_id, @attr)
        expect(@attr[:input_type_id]).to eq(input_types[input_type_name]["id"])
      end
    end

    describe ".set_regular_expression_id" do
      let(:regxp_name) { "location" }
      before do
        @attr = {"regular_expression" => regxp_name }
      end

      it "正しいregular_expression_idをハッシュにマージしていること" do
        Sengu::VDB::Mapping.send(:set_regular_expression_id, @attr)
        expect(@attr[:regular_expression_id]).to eq(regular_expressions[regxp_name]["id"])
      end
    end

    describe ".set_code_list" do
      let(:code_list_name) { "menseki_tani" }
      before do
        Vocabulary::Element.create(code_lists[code_list_name])
        @attr = {"input_type" => "it_pulldown_vocabulary", "code_list" => code_list_name }
      end

      it "正しいsource_typeをハッシュにマージしていること" do
        Sengu::VDB::Mapping.send(:set_code_list, @attr)
        expect(@attr[:source_type]).to eq("Vocabulary::Element")
      end

      it "正しいsource_idをハッシュにマージしていること" do
        Sengu::VDB::Mapping.send(:set_code_list, @attr)
        expect(@attr[:source_id]).to eq(code_lists[code_list_name]["id"])
      end
    end
  end
end
