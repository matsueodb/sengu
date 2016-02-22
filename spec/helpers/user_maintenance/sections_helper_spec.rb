require 'spec_helper'

describe UserMaintenance::SectionsHelper do
  describe "#options_for_select_with_users" do
    let(:users){(1..11).map{create(:editor_user)}}

    it "選択肢がOptionタグで返ること" do
      result = users.map{|s|%Q(<option value="#{s.id}">#{s.name}</option>)}.join("\n")
      expect(helper.options_for_select_with_users(users)).to eq(result)
    end

    it "第２引数で渡したIDの所属が選択中となり、選択肢がOptionタグで返ること" do
      selected = users.last.id
      result = users.map{|s|%Q(<option #{('selected="selected" ' if s.id == selected)}value="#{s.id}">#{s.name}</option>)}.join("\n")
      expect(helper.options_for_select_with_users(users, selected)).to eq(result)
    end
  end
end
