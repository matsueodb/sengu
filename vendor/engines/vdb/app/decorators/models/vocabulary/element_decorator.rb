Vocabulary::Element.class_eval do

  #
  #=== 語彙データベースシステムからコードリストを更新する
  #
  def update_by_vdb
    if self.from_vdb? && code_list = VocabularySearch.find(name: self.name)
      exists_vals = self.values.to_a
      check = true
      update_vals = code_list.to_vocabulary_element.values.each_with_object([]) do |v, vals|
        vals << Vocabulary::ElementValue.find_or_initialize_by(name: v.name)
      end
      (exists_vals - update_vals).each do |destroy_val|
        if ElementValue.where('elements.source_id = ? AND elements.source_type = ? AND kind = ?', self.id, Vocabulary::Element.name, destroy_val.id).joins(:element).exists?
          check = false
          break
        end
      end
      if check
        self.values = update_vals
        return true
      else
        return false
      end
    else
      return false
    end
  end

  #
  #=== RDFで使用するURLを返却する
  #
  def about_url_for_rdf_with_vdb
    if self.from_vdb?
      # coreではなく、domain固定
      # 今後coreからもコードリストが取れる場合は、ドメイン識別子をデータとして持たせておかないといけない
      Sengu::VDB::Domain.get_vocabulary_url(Settings.vdb.api_ids.find_id, getname: self.name, relateflg: "1").to_s
    else
      nil
    end
  end

  alias_method_chain :about_url_for_rdf, :vdb
end
