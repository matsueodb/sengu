# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'spec_helper'

describe Service do
  describe "バリデーション" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :section_id }
    it { should ensure_length_of(:name).is_at_most(255) }
  end

  describe "assocition" do
    it{should have_many(:templates)}
    it{should have_many(:extensions)}
    it{should belong_to(:user)}
    it{should belong_to(:section)}
  end

  describe "scope" do
    describe "#displayables" do
      subject{ Service.displayables(user) }

      context "自分がユーザグループに所属していない場合" do
        let(:section) { create(:section) }
        let(:user) { create(:editor_user, section_id: section.id) }

        before do
          @services = create_list(:service, 5, section_id: section.id)
        end

        it "自分の所属が作成したサービスを返却すること" do
          expect(subject).to match_array(@services)
        end
      end

      context "自分がユーザグループに属している場合" do
        let(:section) { create(:section) }
        let(:user) { create(:editor_user, section_id: section.id) }
        let(:another_section) { create(:section) }
        let(:another_user) { create(:editor_user, section_id: another_section.id) }

        before do
          group = create(:user_group, section_id: another_section.id)
          group.users << user
          @services = create_list(:service, 5, section_id: section.id)
          @services.concat((1..5).map{create(:service, section_id: another_section.id, templates: [create(:template, user_group_id: group.id)])})
        end

        it "自分の所属が作成したサービスと自分が属するグループが割り当てられたテンプレートのサービスを返却すること" do
          subject
          expect(subject).to match_array(@services)
        end
      end
    end
  end

  describe "method" do
    let(:service){create(:service)}

    describe "#addable_template?" do
      let(:section){create(:section)}
      let(:user){create(:section_manager_user, section_id: section.id)}

      subject{service.addable_template?(user)}

      context "サービスの所属と引数で渡したユーザの所属が同じのとき" do
        before{service.update!(section_id: section.id)}

        it "ユーザが管理者の場合、trueが返ること" do
          user.update!(authority: User.authorities[:admin])
          expect(subject).to be_true
        end

        it "ユーザが所属管理者の場合、trueが返ること" do
          user.update!(authority: User.authorities[:section_manager])
          expect(subject).to be_true
        end

        it "ユーザがデータ登録者の場合、falseが返ること" do
          user.update!(authority: User.authorities[:editor])
          expect(subject).to be_false
        end
      end

      it "サービスの所属と引数で渡したユーザの所属が違う場合、falseが返ること" do
        service.update!(section_id: 0)
        expect(subject).to be_false
      end
    end

    describe "#operator?" do
      subject{service.operator?(user)}

      context "自分の所属のサービス内のテンプレートの場合" do
        let(:service) { create(:service, user_id: user.id, section_id: section.id) }
        let(:section) { create(:section) }

        context "引数で渡されたユーザが所属の管理者の場合" do
          let(:user) { create(:section_manager_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_true
          end
        end

        context "引数で渡されたユーザが管理者の場合" do
          let(:user) { create(:super_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_true
          end
        end

        context "引数で渡されたユーザがデータ登録者の場合" do
          let(:user) { create(:editor_user, section_id: section.id) }

          it "trueが返ること" do
            expect(subject).to be_false
          end
        end
      end
    end

    describe "#managed_by?" do
      let(:section) { create(:section) }
      let(:service) { create(:service, section_id: section.id) }

      context "引数で渡した所属のサービスの場合" do

        it "trueが返ること" do
          expect(service.managed_by?(section)).to be_true
        end
      end

      context "引数で渡した所属のサービスではない場合" do
        let(:other_section) { create(:section) }

        it "falseが返ること" do
          expect(service.managed_by?(other_section)).to be_false
        end
      end
    end
  end
end
