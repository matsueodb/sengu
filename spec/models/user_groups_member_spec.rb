# == Schema Information
#
# Table name: user_groups_members
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  group_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe UserGroupsMember do
  describe "validation" do
    it { should validate_uniqueness_of(:user_id).scoped_to(:group_id)  }
  end
end
