# == Schema Information
#
# Table name: kokudo_cities
#
#  id      :integer          not null, primary key
#  name    :string(255)
#  pref_id :integer
#

require 'spec_helper'

describe KokudoCity do
  describe "association" do
    it {should have_many(:addresses).class_name("KokudoAddress")}
    it {should belong_to(:pref).class_name("KokudoPref")}
  end
end
