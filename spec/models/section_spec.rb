require 'spec_helper'

describe Section do
  describe "association" do
    it{should have_many(:users)}
    it{should have_many(:user_groups)}
  end

  describe "validation" do
    it {should validate_presence_of :name}
    it {should ensure_length_of(:name).is_at_most(255) }
    it { should validate_uniqueness_of(:name)}
    it {should ensure_length_of(:copyright).is_at_most(255) }
  end

  describe "method" do
    let(:section){create(:section)}
    subject{section.destroyable?}

    describe "#destroyable?" do
      it "所属にユーザがいない場合、Trueが返ること" do
        expect(subject).to be_true
      end

      it "所属にユーザがいる場合、falseが返ること" do
        section.users << create(:editor_user)
        expect(subject).to be_false
      end
    end

    describe "#editable?" do
      let(:user){create(:editor_user)}

      subject{section.editable?(user)}

      it "運用管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:admin])
        expect(subject).to be_true
      end

      it "所属の管理者の場合、trueが返ること" do
        user.update!(section_id: section.id, authority: User.authorities[:section_manager])
        expect(subject).to be_true
      end

      it "所属の管理者以外の場合、falseが返ること" do
        user.update!(section_id: section.id, authority: User.authorities[:editor])
        expect(subject).to be_false
      end
    end

    describe "#addable_user?" do
      let(:user){create(:editor_user)}

      subject{section.addable_user?(user)}

      it "引数で渡したユーザが管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:admin], section_id: create(:section).id)
        expect(subject).to be_true
      end

      it "引数で渡したユーザが所属管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:section_manager], section_id: section.id)
        expect(subject).to be_true
      end

      it "引数で渡したユーザが他の所属の所属管理者の場合、falseが返ること" do
        user.update!(authority: User.authorities[:section_manager], section_id: create(:section).id)
        expect(subject).to be_false
      end

      it "引数で渡したユーザがデータ登録者の場合、falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "#addable_user_group?" do
      let(:user){create(:editor_user)}

      subject{section.addable_user_group?(user)}

      it "引数で渡したユーザが管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:admin], section_id: create(:section).id)
        expect(subject).to be_true
      end

      it "引数で渡したユーザが所属管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:section_manager], section_id: section.id)
        expect(subject).to be_true
      end

      it "引数で渡したユーザが他の所属の所属管理者の場合、falseが返ること" do
        user.update!(authority: User.authorities[:section_manager], section_id: create(:section).id)
        expect(subject).to be_false
      end

      it "引数で渡したユーザがデータ登録者の場合、falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "#manager?" do
      let(:user){create(:editor_user)}

      subject{section.manager?(user)}

      it "所属の管理者の場合、trueが返ること" do
        user.update!(section_id: section.id, authority: User.authorities[:section_manager])
        expect(subject).to be_true
      end

      it "所属の管理者以外の場合、falseが返ること" do
        user.update!(section_id: section.id, authority: User.authorities[:editor])
        expect(subject).to be_false
      end
    end

    describe "#displayable?" do
      let(:user){create(:editor_user)}

      subject{section.displayable?(user)}

      it "運用管理者の場合、trueが返ること" do
        user.update!(authority: User.authorities[:admin])
        expect(subject).to be_true
      end

      it "所属の管理者の場合、trueが返ること" do
        user.update!(section_id: section.id, authority: User.authorities[:section_manager])
        expect(subject).to be_true
      end

      it "所属のメンバーの場合、trueが返ること" do
        user.update!(section_id: section.id)
        expect(subject).to be_true
      end

      it "所属のメンバー以外の場合、falseが返ること" do
        user.update!(section_id: 0, authority: User.authorities[:editor])
        expect(subject).to be_false
      end
    end
  end
end
