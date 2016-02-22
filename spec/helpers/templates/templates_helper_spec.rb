require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Templates::TemplatesHelper. For example:
#
# describe Templates::TemplatesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
describe Templates::TemplatesHelper do
  describe "options_for_select_with_user_groups" do
    let(:user_group1){create(:user_group)}
    let(:user_group2){create(:user_group)}
    let(:user_group3){create(:user_group)}
    let(:user_groups){[user_group1, user_group2, user_group3]}

    it "user_groupsをもとにプルダウンが生成されること" do
      options = [%Q(<option selected=\"selected\" value=\"\">#{I18n.t("shared.non_select")}</option>)]
      options += user_groups.map do |ug|
        %Q(<option value=\"#{ug.id}\">#{ug.name}</option>)
      end
      expect(helper.options_for_select_with_user_groups(user_groups)).to eq(options.join("\n"))
    end

    it "第２引数で渡した値のIDをもつオプションタグがselectedになること" do
      options = [%Q(<option value=\"\">#{I18n.t("shared.non_select")}</option>)]
      options << %Q(<option value=\"#{user_group1.id}\">#{user_group1.name}</option>)
      options << %Q(<option selected=\"selected\" value=\"#{user_group2.id}\">#{user_group2.name}</option>)
      options << %Q(<option value=\"#{user_group3.id}\">#{user_group3.name}</option>)
      expect(helper.options_for_select_with_user_groups(user_groups, user_group2.id)).to eq(options.join("\n"))
    end
  end
  
  describe "options_for_select_with_services" do
    let(:service1){create(:service)}
    let(:service2){create(:service)}
    let(:service3){create(:service)}
    let(:services){[service1, service2, service3]}

    it "servicesをもとにプルダウンが生成されること" do
      options = services.map do |ug|
        %Q(<option value=\"#{ug.id}\">#{ug.name}</option>)
      end
      expect(helper.options_for_select_with_services(services)).to eq(options.join("\n"))
    end

    it "options[:blank]=trueを渡すと、プルダウンの先頭に未選択がセットされること" do
      options = [%Q(<option selected=\"selected\" value=\"\">#{I18n.t("shared.non_select")}</option>)]
      options += services.map do |ug|
        %Q(<option value=\"#{ug.id}\">#{ug.name}</option>)
      end
      expect(helper.options_for_select_with_services(services, "", blank: true)).to eq(options.join("\n"))
    end

    it "第２引数で渡した値のIDをもつオプションタグがselectedになること" do
      options = []
      options << %Q(<option value=\"#{service1.id}\">#{service1.name}</option>)
      options << %Q(<option selected=\"selected\" value=\"#{service2.id}\">#{service2.name}</option>)
      options << %Q(<option value=\"#{service3.id}\">#{service3.name}</option>)
      expect(helper.options_for_select_with_services(services, service2.id)).to eq(options.join("\n"))
    end
  end

  describe "options_for_select_with_string_conditions" do
    it "TemplateRecordSelectCondition::STRING_CONDITIONをもとにプルダウンが生成されること" do
      options = TemplateRecordSelectCondition::STRING_CONDITION.map do |key, val|
        name = I18n.t("template_record_select_condition.string_conditions.#{key.to_s}")
        %Q(<option value=\"#{key}\">#{name}</option>)
      end
      expect(helper.options_for_select_with_string_conditions()).to eq(options.join("\n"))
    end

    it "引数で渡した値のIDをもつオプションタグがselectedになること" do
      options = TemplateRecordSelectCondition::STRING_CONDITION.map do |key, val|
        name = I18n.t("template_record_select_condition.string_conditions.#{key.to_s}")
        if key == :middle_match
          %Q(<option selected=\"selected\" value=\"#{key}\">#{name}</option>)
        else
          %Q(<option value=\"#{key}\">#{name}</option>)
        end
      end
      expect(helper.options_for_select_with_string_conditions("middle_match")).to eq(options.join("\n"))
    end
  end
end
