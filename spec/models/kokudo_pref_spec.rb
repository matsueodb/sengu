# == Schema Information
#
# Table name: kokudo_prefs
#
#  id   :integer          not null, primary key
#  name :string(255)
#

require 'spec_helper'

describe KokudoPref do
  describe "association" do
    it {should have_many(:cities).class_name("KokudoCity")}
  end
end
