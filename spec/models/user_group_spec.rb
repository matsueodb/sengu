# == Schema Information
#
# Table name: user_groups
#
#  id   :integer          not null, primary key
#  name :string(255)
#

require 'spec_helper'

describe UserGroup do
  let(:section){create(:section)}
  let(:user_group){create(:user_group, section: section)}
  let(:user){create(:super_user)}

  describe "association" do
    it {should have_many(:templates)}
    it {should have_many(:user_groups_members).dependent(:destroy) }
    it {should have_many(:users).through(:user_groups_members) }
    it {should belong_to(:section) }
  end
  describe "validation" do
    it {should validate_presence_of :name}
    it {should ensure_length_of(:name).is_at_most(255) }
    it {should validate_presence_of :section_id}
  end
  
  describe "method" do
    describe "#member?" do
      subject{user_group.member?(user)}

      it "引数で渡したユーザがUserGroupのメンバーの場合、trueが返ること" do
        user_group.user_groups_members.create(user_id: user.id)
        expect(subject).to be_true
      end

      it "引数で渡したユーザがUserGroupのメンバーではない場合、falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "#has_template?" do
      subject{user_group.has_template?}

      it "グループがテンプレートに設定されている場合、trueが返ること" do
        create(:template, user_group_id: user_group.id)
        expect(subject).to be_true
      end

      it "グループがテンプレートに設定されていない場合、falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "#destroyable?" do
      subject{user_group.destroyable?}

      it "has_template?がfalse場合、trueが返ること" do
        user_group.stub(:has_template?){false}
        expect(subject).to be_true
      end

      it "has_template?がtrue場合、falseが返ること" do
        user_group.stub(:has_template?){true}
        expect(subject).to be_false
      end
    end
  end
end
