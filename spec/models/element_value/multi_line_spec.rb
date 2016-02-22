# == Schema Information
#
# Table name: element_value_text_contents
#
#  id         :integer          not null, primary key
#  value      :text
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::MultiLine do
  let(:content){create(:element_value_multi_line)}
  
  describe "methods" do
  end
end
