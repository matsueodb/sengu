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

class UserGroupsMember < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_group, foreign_key: :group_id

  validates :user_id, uniqueness: {scope: :group_id}
end
