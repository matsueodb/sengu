module UserMaintenance::Sections::UsersHelper
  #
  #=== 所属のプルダウンを返す
  #
  def options_for_select_with_sections(sections, selected = "")
    lists = sections.map{|s|[s.name, s.id]}
    options_for_select(lists, selected.to_i)
  end
end
