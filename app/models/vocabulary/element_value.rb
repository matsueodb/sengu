# == Schema Information
#
# Table name: vocabulary_element_values
#
#  id         :integer          not null, primary key
#  element_id :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

#
#=== 語彙要素（単語）
#
class Vocabulary::ElementValue < ActiveRecord::Base
  validates :name,
    presence: true,
    length: { maximum: 255 }
end
