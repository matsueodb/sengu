module Templates::TemplatesHelper
  #
  #=== UserGroupsのセレクトを表示する。
  #
  #==== 引数
  # * user_groups - UserGroup配列
  # * selected - デフォルトの選択値
  def options_for_select_with_user_groups(user_groups, selected = "")
    lists = user_groups.map{|ug|[ug.name, ug.id]}
    lists.unshift([t("shared.non_select"), ""])

    options_for_select(lists, selected.to_s)
  end

  #
  #=== Serviceのセレクトを表示する。
  #
  #==== 引数
  # * services - Service配列
  # * selected - デフォルトの選択値
  def options_for_select_with_services(services, selected = "", options={})
    lists = services.map{|s|[s.name, s.id]}
    lists.unshift([t("shared.non_select"), ""]) if options[:blank]
    options_for_select(lists, selected.to_s)
  end

  #
  #=== Serviceのセレクトを表示する。
  def options_for_select_with_string_conditions(selected = "")
    lists = TemplateRecordSelectCondition::STRING_CONDITION.map do |k, _v|
      [t("template_record_select_condition.string_conditions.#{k.to_s}"), k]
    end
    options_for_select(lists, selected.to_s)
  end
end
