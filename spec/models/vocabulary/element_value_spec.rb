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

require 'spec_helper'

describe Vocabulary::ElementValue do
  describe "バリデーション" do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_most(255) }
  end
end
