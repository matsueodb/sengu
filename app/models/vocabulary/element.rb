# == Schema Information
#
# Table name: vocabulary_elements
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  from_vdb    :boolean          default(FALSE)
#

class Vocabulary::Element < ActiveRecord::Base
  has_many :elements, as: :source, class_name: "::Element"
  has_many :values, -> { order(:id) }, class_name: 'Vocabulary::ElementValue', dependent: :delete_all

  validates :name,
    presence: true,
    length: { maximum: 255 }

  accepts_nested_attributes_for :values

  #
  #=== Elementから実際に参照されるデータを返す。
  # Elementとsourceでリレーションしているクラスでは必ず必要なメソッド
  #==== 戻り値
  # * TemplateRecordリレーション
  def records_referenced_from_element
    self.values
  end

  def destroyable?
    !self.elements.exists?
  end

  #
  #=== RDFで使用するURLを返却する
  #
  def about_url_for_rdf
    Rails.application.routes.url_helpers.vocabulary_element_values_path(self)
  end
end
