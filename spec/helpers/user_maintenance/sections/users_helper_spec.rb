require 'spec_helper'

describe UserMaintenance::Sections::UsersHelper do
  describe "#options_for_select_with_sections" do
    let(:sections){(1..11).map{create(:section)}}

    it "選択肢がOptionタグで返ること" do
      result = sections.map{|s|%Q(<option value="#{s.id}">#{s.name}</option>)}.join("\n")
      expect(helper.options_for_select_with_sections(sections)).to eq(result)
    end

    it "第２引数で渡したIDの所属が選択中となり、選択肢がOptionタグで返ること" do
      selected = sections.last.id
      result = sections.map{|s|%Q(<option #{('selected="selected" ' if s.id == selected)}value="#{s.id}">#{s.name}</option>)}.join("\n")
      expect(helper.options_for_select_with_sections(sections, selected)).to eq(result)
    end
  end
end
