require 'spec_helper'

describe UserGroupsMemberSearch do
  describe "validation" do
    it {should validate_presence_of :login}

    describe "#validate_user" do
      it "self.userがnilの場合、エラーがセットされること" do
        expect(UserGroupsMemberSearch.new(login: "not_find_login")).to have(1).errors_on(:user)
      end

      it "self.user.section_idとself.user_group.section_idが等しい場合、エラーとなること" do
        section = create(:section)
        user = create(:editor_user, section_id: section.id)
        user_group = create(:user_group, section_id: section.id)
        ugms = UserGroupsMemberSearch.new(login: user.login, user_group_id: user_group.id)

        expect(ugms).to have(1).errors_on(:user)
      end
    end
  end

  describe "callbacks" do
    describe "before_validation" do
      describe "#set_user_from_login" do
        let(:user){create(:editor_user)}
        let(:ugms){UserGroupsMemberSearch.new(login: user.login)}
        
        subject{ugms.valid?}

        it "loginをもとにself.userにUserモデルから取得してセットされること" do
          expect{subject}.to change{ugms.user}.from(nil).to(user)
        end
      end

      describe "#set_user_group_from_user_group_id" do
        let(:user_group){create(:user_group)}
        let(:ugms){UserGroupsMemberSearch.new(user_group_id: user_group.id)}

        subject{ugms.valid?}

        it "user_group_idをもとにself.user_groupにUserGroupモデルから取得してセットされること" do
          expect{subject}.to change{ugms.user_group}.from(nil).to(user_group)
        end
      end
    end
  end

  describe "method" do
    describe "#user_registered?" do
      let(:user){create(:editor_user)}
      let(:user_group){create(:user_group)}
      let(:ugms){UserGroupsMemberSearch.new(login: user.login, user_group_id: user_group.id)}

      before do
        ugms.valid?
      end

      subject{ugms.user_registered?}

      context "@user_registeredがnilの場合" do
        context "グループにユーザが登録されている場合" do
          before do
            user_group.users << user
          end
          
          it "trueが返ること" do
            expect(subject).to be_true
          end

          it '@user_registeredに"true"がセットされること' do
            subject
            expect(ugms.instance_variable_get(:@user_registered)).to eq("true")
          end
        end

        context "グループにユーザが登録されていない場合" do
          it "falseが返ること" do
            expect(subject).to be_false
          end

          it '@user_registeredに"false"がセットされること' do
            subject
            expect(ugms.instance_variable_get(:@user_registered)).to eq("false")
          end
        end
      end

      it "@user_registeredに'true'がセットされている場合、trueが返ること" do
        ugms.instance_eval do
          @user_registered = "true"
        end
        expect(subject).to be_true
      end

      it "@user_registeredに'false'がセットされている場合、falseが返ること" do
        ugms.instance_eval do
          @user_registered = "false"
        end
        expect(subject).to be_false
      end
    end

    describe "private" do
      let(:ugms){UserGroupsMemberSearch.new}
      
      describe "#set_user_from_login" do
        let(:user){create(:editor_user)}

        before do
          ugms.login = user.login
        end

        subject{ugms.send(:set_user_from_login)}
        
        it "self.userにself.loginの値のログインIDをもつユーザがセットされること" do
          expect{subject}.to change{ugms.user}.from(nil).to(user)
        end
      end

      describe "#set_user_group_from_user_group_id" do
        let(:user_group){create(:user_group)}

        before do
          ugms.user_group_id = user_group.id
        end

        subject{ugms.send(:set_user_group_from_user_group_id)}

        it "self.user_groupにself.user_group_idの値のIDをもつユーザグループがセットされること" do
          expect{subject}.to change{ugms.user_group}.from(nil).to(user_group)
        end
      end
    end
  end
end

