#
#== テンプレート要素の検索を行う
#
class TemplateElementSearch
  include ActiveModel::Model
  CORE_ID = "core"
  DOMAIN_ID = "domain"

  attr_accessor :name, :domain_id, :use_category, :user_id

  validates :domain_id,
    inclusion: {
      in: [nil, CORE_ID, DOMAIN_ID]
    }

  validate do |r|
    if r.name.blank?
      if r.use_category
        r.errors.add(:base, :select_category)
      else
        r.errors.add(:base, :input_keyword)
      end
    end
  end

  def initialize(attr={})
    self.use_category = false if self.use_category.nil?
    super(attr)
  end

  #
  #=== テンプレート要素の検索を行いComplextTypeを返す
  #
  def find_complex
    response = vdb_class.find(@name)
    unless response.success?
      # 200以外のステータスが返ってきたときは、relateflgを変えてアクセスしなおしてみる
      response = vdb_class.find(@name, false)
    end
    response.find_complex_with_getname
  end

  #
  #=== テンプレート要素の検索を行いComplextTypeの配列を返す
  #
  def find_complexes
    error = false
    results = Array.wrap(vdb_class).map do |vdb|
      names.map do |name|
        begin
          response = vdb.find(name)
          # 200以外のステータスが返ってきたときは、relateflgを変えてアクセスしなおしてみる
          # responseがnilのときがあるので、tryを使用する
          response = vdb.find(name, false) unless response.try(:success?)

          errors.add(:base, response.message) if response.fatal?
        rescue ::Sengu::VDB::Base::ConnectionError
          errors.add(:base, I18n.t("sengu.vdb.base.errors.connection"))
        rescue ::Sengu::VDB::Response::ParseError
          errors.add(:base, I18n.t("sengu.vdb.response.errors.parse"))
        end
        response ? response.find_complex_with_getname : []
      end
    end.flatten.compact

    results
  end

  #
  #=== テンプレート要素の検索を行いElementを返す
  #
  def find_element
    response = vdb_class.find(@name)
    unless response.kind_of?(Net::HTTPOK)

      # 200以外のステータスが返ってきたときは、relateflgを変えてアクセスしなおしてみる
      response = vdb_class.find(@name, false)
    end
    response.find_element_with_getname
  end

  #
  #=== テンプレート要素の検索を行う
  #
  def search(use_keyword: true)
    if valid?
      keywords = use_keyword ? Vocabulary::Keyword.search_by_keyword(name, @user_id).pluck(:name) : []
      results = keywords.unshift(name).map do |keyword|
        Array.wrap(vdb_class).map do |vdb|
          begin
            response = vdb.search(keyword)
            errors.add(:base, response.message) if response.fatal?
          rescue ::Sengu::VDB::Base::ConnectionError
            errors.add(:base, I18n.t("sengu.vdb.base.errors.connection"))
          rescue ::Sengu::VDB::Response::ParseError
            errors.add(:base, I18n.t("sengu.vdb.response.errors.parse"))
          end
          response
        end
      end.flatten.compact

      results
    else
      return false
    end
  end

  #
  #=== ドメインの指定から使用するクラスを返す
  #
  def vdb_class
    case domain_id
    when CORE_ID
      Sengu::VDB::Core
    when DOMAIN_ID
      Sengu::VDB::Domain
    else
      [Sengu::VDB::Core, Sengu::VDB::Domain]
    end
  end

  private

  def names
    if use_category
      Vocabulary::Keyword.search_by_category(@name, @user_id.to_i).pluck(:name)
    else
      Array.wrap(@name)
    end
  end
end
