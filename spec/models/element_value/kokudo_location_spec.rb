# == Schema Information
#
# Table name: element_value_string_contents
#
#  id         :integer          not null, primary key
#  value      :string(255)
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe ElementValue::KokudoLocation do
  let(:content){create(:element_value_kokudo_location)}

  describe "methods" do
  end
end
