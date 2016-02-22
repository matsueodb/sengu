module UserMaintenance::SectionsHelper
  #
  #=== 所属のプルダウンを返す
  #
  def options_for_select_with_users(users, selected = "")
    lists = users.map{|s|[s.name, s.id]}
    options_for_select(lists, selected.to_i)
  end
end
