# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  login              :string(255)      default(""), not null
#  encrypted_password :string(255)      default(""), not null
#  name               :string(255)
#  remarks            :string(255)
#  authority          :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'spec_helper'

describe User do
  let(:section){create(:section)}
  let(:user){create(:editor_user, section_id: section.id)}

  describe "association" do
    it {should have_many(:templates).dependent(:destroy) }
    it {should have_many(:services).dependent(:destroy) }
    it {should have_many(:template_records).dependent(:destroy) }
    it {should have_many(:user_groups_members).dependent(:destroy) }
    it {should have_many(:user_groups).through(:user_groups_members) }
    it {should belong_to(:section)}
  end

  describe "validation" do
    it {should validate_presence_of :name}
    it {should ensure_length_of(:name).is_at_most(255) }
    it {should validate_presence_of :login}
    it {should ensure_length_of(:login).is_at_most(255) }
    it {should ensure_inclusion_of(:authority).in_array(User.authorities.values)}


    context "if login.present?==true" do
      it{should allow_value("abc123-_@").for(:login)}
      it{should_not allow_value("abc123-_@;").for(:login)}
    end

    context "if login_changed?==true" do
      before{User.any_instance.stub(:login_changed?){true}}
      it {should validate_uniqueness_of :login}
    end

    context "if login_changed?==false" do
      before{User.any_instance.stub(:login_changed?){false}}
      it {should_not validate_uniqueness_of :login}
    end

    context "if password_required?==true" do
      before{User.any_instance.stub(:password_required?){true}}
      it {should validate_confirmation_of :password}
      it {should validate_presence_of :password}
    end

    context "if password_required?==false" do
      before{User.any_instance.stub(:password_required?){false}}
      it {should_not validate_confirmation_of :password}
      it {should_not validate_presence_of :password}
    end

    context "if password.present?==true" do
      it {should ensure_length_of(:password).is_at_least(6).is_at_most(30)}
      it{should allow_value("abcDEF123_-").for(:password)}
      it{should_not allow_value("abcDEF123_-*").for(:password)}
    end

    context "if password.present?==false" do
      before{User.any_instance.stub_chain(:password, :present?){false}}
      it {should_not ensure_length_of(:password).is_at_least(6).is_at_most(30)}
      it{should allow_value("abcDEF123_-").for(:password)}
      it{should allow_value("abcDEF123_-*").for(:password)}
    end

    describe "#validates_change_section_id" do
      let(:msg){User.human_attribute_name(:section_id) + I18n.t("user.errors.messages.can_not_change_section_because_it_has_data")}

      context "seciton_idを変更した場合" do
        before{user.section_id = create(:section).id}
        
        it "そのユーザがサービス等のデータを作成している場合、エラーが発生すること" do
          user.stub(:has_rdf_data?){true}
          user.save
          expect(user.errors.full_messages.first).to eq(msg)
        end

        it "そのユーザがサービス等のデータを持っていない場合、エラーが発生しないこと" do
          user.stub(:has_rdf_data?){false}
          user.save
          expect(user).to have(0).error_on(:section_id)
        end
      end
    end
  end

  describe "before_update" do
    it "更新時に、change_section_destroy_groupsが呼ばれること" do
      expect(user).to receive(:change_section_destroy_groups)
      user.update!(authority: 1)
    end

    it "作成時に、change_section_destroy_groupsが呼ばれないこと" do
      u = build(:editor_user)
      expect(user).to_not receive(:change_section_destroy_groups)
      u.save!
    end
  end

  describe "method" do
    describe "#admin?" do
      subject{user.admin?}

      it "authority==User.authorities[:admin]の場合、trueが返ること" do
        user.stub(:authority){User.authorities[:admin]}
        expect(subject).to be_true
      end

      it "authority!=User.authorities[:admin]の場合、falseが返ること" do
        user.stub(:authority){User.authorities[:editor]}
        expect(subject).to be_false
      end
    end

    describe "#editor?" do
      subject{user.editor?}

      it "authority==User.authorities[:editor]の場合、trueが返ること" do
        user.stub(:authority){User.authorities[:editor]}
        expect(subject).to be_true
      end

      it "authority!=User.authorities[:editor]の場合、falseが返ること" do
        user.stub(:authority){User.authorities[:admin]}
        expect(subject).to be_false
      end
    end

    describe "#section_manager?" do
      subject{user.section_manager?}

      it "authority==User.authorities[:section_manager]の場合、trueが返ること" do
        user.stub(:authority){User.authorities[:section_manager]}
        expect(subject).to be_true
      end

      it "authority!=User.authorities[:section_manager]の場合、falseが返ること" do
        user.stub(:authority){User.authorities[:admin]}
        expect(subject).to be_false
      end
    end

    describe "#manager?" do
      subject{user.manager?}

      it "authority==User.authorities[:admin]の場合、trueが返ること" do
        user.stub(:authority){User.authorities[:admin]}
        expect(subject).to be_true
      end

      it "authority==User.authorities[:section_manager]の場合、trueが返ること" do
        user.stub(:authority){User.authorities[:section_manager]}
        expect(subject).to be_true
      end

      it "authority!=User.authorities[:editor]の場合、falseが返ること" do
        user.stub(:authority){User.authorities[:editor]}
        expect(subject).to be_false
      end
    end

    describe "#update_with_password!" do
      subject{user.update_with_password!({}, user)}

      it "clean_up_passwordsが呼ばれること" do
        user.should_receive(:clean_up_passwords)
        subject
      end

      context "paramsに:passwordがblankの場合" do
        let(:base_params){{name: "テストユーザA"}}

        context "parasm[:password_confirmation]がblankの場合" do
          let(:params){base_params.merge({password: "", password_confirmation: ""})}
          subject{user.update_with_password!(params, user)}

          it "paramsから:passwordと:password_confirmationのキーが削除されたものを引数に渡してattributes=が呼ばれること" do
            user.should_receive(:attributes=).with(base_params)
            subject
          end

          it "save!が呼ばれること" do
            user.should_receive(:save!)
            subject
          end
        end

        context "parasm[:password_confirmation]がある場合" do
          let(:params){base_params.merge({password: "", password_confirmation: "testtest"})}
          subject{user.update_with_password!(params, user)}

          it "paramsから:passwordのキーが削除されたものを引数に渡してattributes=が呼ばれること" do
            result = params.dup
            result.delete(:password)
            user.should_receive(:attributes=).with(result)
            subject
          end

          it "save!が呼ばれること" do
            user.should_receive(:save!)
            subject
          end
        end
      end

      context "paramsに:passwordがある場合" do
        let(:base_params){{name: "テストユーザA"}}
        let(:params){base_params.merge({password: "testest", password_confirmation: "testtest"})}
        subject{user.update_with_password!(params, user)}

        it "paramsにセットした値を引数に渡してattributes=が呼ばれること" do
          user.should_receive(:attributes=).with(params)
          subject
        end

        it "save!が呼ばれること" do
          user.should_receive(:save!)
          subject
        end
      end
    end
    
    describe "#inherit_data" do
      let(:to_user){create(:editor_user)}
      let(:from_user){create(:editor_user)}
      before do
        3.times do
          create(:service, user_id: from_user.id)
          te = create(:template, user_id: from_user.id)
          create(:template_record, template_id: te.id, user_id: from_user.id)
          ug = create(:user_group)
          ug.users << from_user
        end
        to_user.reload
        from_user.reload
      end

      subject{from_user.inherit_data(to_user)}

      it "from_userの作成したTemplateRecordのuser_idがto_user.idに変わること" do
        from = (1..3).to_a.map{from_user.id}
        result = (1..3).to_a.map{to_user.id}
        expect{subject}.to change{TemplateRecord.pluck(:user_id)}.from(from).to(result)
      end
    end

    describe "#accessible?" do
      let(:section){create(:section)}
      let(:user1){create(:editor_user, section_id: section.id)}

      it "引数で渡したユーザが管理者の場合、trueが返ること" do
        u = create(:super_user)
        expect(user1.accessible?(u)).to be_true
      end

      context "ユーザが管理者ではなく" do
        it "ユーザが引数で渡したユーザと等しい場合、trueが返ること" do
          expect(user1.accessible?(user1)).to be_true
        end

        context "ユーザが引数で渡したユーザと等しくなく" do
          it "引数で渡したユーザがユーザの所属の管理者の場合、trueが返ること" do
            u = create(:section_manager_user, section_id: section.id)
            expect(user1.accessible?(u)).to be_true
          end

          it "引数で渡したユーザがユーザの所属の管理者ではない場合、falseが返ること" do
            u = create(:editor_user, section_id: section.id)
            expect(user1.accessible?(u)).to be_false
          end
        end
      end
    end
    
    describe "#editable?" do
      let(:section){create(:section)}
      let(:user1){create(:editor_user, section_id: section.id)}

      it "引数で渡したユーザが管理者の場合、trueが返ること" do
        u = create(:super_user)
        expect(user1.editable?(u)).to be_true
      end

      context "ユーザが管理者ではなく" do
        it "ユーザが引数で渡したユーザと等しい場合、trueが返ること" do
          expect(user1.editable?(user1)).to be_true
        end

        context "ユーザが引数で渡したユーザと等しくなく" do
          it "引数で渡したユーザがユーザの所属の管理者の場合、trueが返ること" do
            u = create(:section_manager_user, section_id: section.id)
            expect(user1.editable?(u)).to be_true
          end

          it "引数で渡したユーザがユーザの所属の管理者ではない場合、falseが返ること" do
            u = create(:editor_user, section_id: section.id)
            expect(user1.editable?(u)).to be_false
          end
        end
      end
    end

    describe "#destroyable?" do
      let(:section){create(:section)}
      let(:user1){create(:editor_user, section_id: section.id)}

      it "引数で渡したユーザが管理者の場合、trueが返ること" do
        u = create(:super_user)
        expect(user1.editable?(u)).to be_true
      end

      context "ユーザが管理者ではなく" do
        it "引数で渡したユーザがユーザの所属の管理者の場合、trueが返ること" do
          u = create(:section_manager_user, section_id: section.id)
          expect(user1.editable?(u)).to be_true
        end

        it "引数で渡したユーザがユーザの所属の管理者ではない場合、falseが返ること" do
          u = create(:editor_user)
          expect(user1.editable?(u)).to be_false
        end
      end
    end

    describe "#has_rdf_data?" do
      subject{user.has_rdf_data?}

      it "ユーザが作成したデータがある場合、trueが返ること" do
        te = create(:template, user_id: 0)
        create(:template_record, user_id: user.id, template_id: te.id)
        user.reload
        expect(subject).to be_true
      end

      it "ユーザが作成したデータがない場合、falseが返ること" do
        expect(subject).to be_false
      end
    end

    describe "protected" do
      describe "#password_required?" do
        it "新規インスタンスの場合Trueが返ること" do
          expect(build(:super_user).send(:password_required?)).to be_true
        end

        context "既存レコードのインスタンスの場合" do
          subject{user.send(:password_required?)}

          it "passwordがnilではない場合、trueが返ること" do
            user.stub(:password){"testtest"}
            expect(subject).to be_true
          end

          context "passwordがnilの場合" do
            before{user.stub(:password){nil}}

            it "password_confirmationがnilの場合、falseが返ること" do
              user.stub(:password_confirmation){nil}
              expect(subject).to be_false
            end

            it "password_confirmationがnilではない場合、trueが返ること" do
              user.stub(:password_confirmation){"testtest"}
              expect(subject).to be_true
            end
          end
        end
      end
    end

    describe "private" do
      describe "#change_section_destroy_groups" do
        subject{user.save!}
        
        before do
          5.times do
            create(:user_group, users: [user], section_id: section.id)
            create(:user_group, users: [user], section_id: 0)
          end
        end

        it "section_idを変更したとき、ユーザが参加していたグループから外されること" do
          user.section_id = 0
          expect{subject}.to change{UserGroupsMember.joins(:user_group).where("section_id = ?", section.id).where(user_id: user.id).count}.from(5).to(0)
        end

        it "section_idを変更していない場合は、ユーザが参加していたグループから外されないこと" do
          user.authority = 0
          expect{subject}.to_not change{UserGroupsMember.joins(:user_group).where("section_id = ?", section.id).where(user_id: user.id).count}.from(5).to(0)
        end
      end

      describe "#validates_change_section_id" do
        let(:msg){User.human_attribute_name(:section_id) + I18n.t("user.errors.messages.can_not_change_section_because_it_has_data")}

        subject{user.send(:validates_change_section_id)}

        context "seciton_idを変更した場合" do
          before{user.section_id = create(:section).id}

          it "そのユーザがサービス等のデータを作成している場合、エラーが発生すること" do
            user.stub(:has_rdf_data?){true}
            subject
            expect(user.errors.full_messages.first).to eq(msg)
          end

          it "そのユーザがサービス等のデータを持っていない場合、エラーが発生しないこと" do
            user.stub(:has_rdf_data?){false}
            subject
            expect(user).to have(0).error_on(:section_id)
          end
        end
      end
    end
  end
end
