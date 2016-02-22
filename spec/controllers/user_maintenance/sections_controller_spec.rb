require 'spec_helper'

describe UserMaintenance::SectionsController do
  describe "filter" do
    let(:section){create(:section)}
    let(:admin_user){create(:super_user)}
    let(:user){create(:editor_user, section_id: section.id)}
    
    controller do
      %w(index new show edit create update destroy).each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous
      end
    end

    describe "#authenticate_user!" do
      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "ログイン時のアクセス制限" do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:set_section)
        controller.stub(:creatable_check)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
        controller.stub(:displayable_check)
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("未ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("未ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end
    end

    describe "#set_section" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@sectionがセットされていること" do
          expect(assigns[:section]).to eq(section)
        end
      end

      before do
        login_user(user)
        controller.stub(:creatable_check)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
        controller.stub(:displayable_check)
      end

      it_behaves_like("インスタンス変数の確認", :get, :show){before{get :show, id: section.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: section.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update){before{patch :update, id: section.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy){before{delete :destroy, id: section.id}}
    end

    describe "#creatable_check" do
      shared_examples_for "アクセス権がないユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属管理画面にリダイレクトすること" do
          expect(subject).to redirect_to(sections_path)
        end
      end

      shared_examples_for "アクセス権があるユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:set_section)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
        controller.stub(:displayable_check)
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(admin_user)}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :new){subject{get :new}}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :post, :create){subject{post :create}}
      end

      context "ログインユーザが一般ユーザの場合" do
        before{login_user(user)}
        it_behaves_like("アクセス権がないユーザのアクセス制限確認", :get, :new){subject{get :new}}
        it_behaves_like("アクセス権がないユーザのアクセス制限確認", :post, :create){subject{post :create}}
      end
    end

    describe "#editable_check" do
      shared_examples_for "アクセス権がないユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属管理画面にリダイレクトすること" do
          expect(subject).to redirect_to(sections_path)
        end
      end

      shared_examples_for "アクセス権があるユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:set_section)
        sec = section
        controller.instance_eval do
          @section = sec
        end
        controller.stub(:creatable_check)
        controller.stub(:destroyable_check)
        controller.stub(:displayable_check)
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(admin_user)}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :edit){subject{get :edit, id: section.id}}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :patch, :update){subject{patch :update, id: section.id}}
      end
      
      context "ログインユーザが所属の管理者の場合" do
        before do
          user.update!(section_id: section.id, authority: User.authorities[:section_manager])
          login_user(user)
        end
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :edit){subject{get :edit, id: section.id}}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :patch, :update){subject{patch :update, id: section.id}}
      end

      context "ログインユーザが一般ユーザの場合" do
        before do
          user.update!(section_id: section.id, authority: User.authorities[:editor])
          login_user(user)
        end
        it_behaves_like("アクセス権がないユーザのアクセス制限確認", :get, :edit){subject{get :edit, id: section.id}}
        it_behaves_like("アクセス権がないユーザのアクセス制限確認", :patch, :update){subject{patch :update, id: section.id}}
      end
    end

    describe "#displayable_check" do
      shared_examples_for "アクセス権がないユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属管理画面にリダイレクトすること" do
          expect(subject).to redirect_to(sections_path)
        end
      end

      shared_examples_for "アクセス権があるユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:set_section)
        sec = section
        controller.instance_eval do
          @section = sec
        end
        controller.stub(:creatable_check)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(admin_user)}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :show){subject{get :show, id: section.id}}
      end

      context "ログインユーザが所属の管理者の場合" do
        before do
          user.update!(section_id: section.id, authority: User.authorities[:section_manager])
          login_user(user)
        end
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :show){subject{get :show, id: section.id}}
      end

      context "ログインユーザが一般ユーザの場合" do
        context "ログインユーザが該当の所属に属するユーザの場合" do
          before do
            login_user(user)
          end
          it_behaves_like("アクセス権があるユーザのアクセス制限確認", :get, :show){subject{get :show, id: section.id}}
        end

        context "ログインユーザが他の所属のユーザの場合" do
          before do
            user.update!(section_id: 0)
            login_user(user)
          end
          it_behaves_like("アクセス権がないユーザのアクセス制限確認", :get, :show){subject{get :show, id: section.id}}
        end
      end
    end
    
    describe "#destroyable_check" do
      shared_examples_for "アクセス権がないユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、所属管理画面にリダイレクトすること" do
          expect(subject).to redirect_to(sections_path)
        end
      end

      shared_examples_for "アクセス権があるユーザのアクセス制限確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、正しく画面が表示されること" do
          subject
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:set_section)
        sec = section
        controller.instance_eval do
          @section = sec
        end
        controller.stub(:creatable_check)
        controller.stub(:editable_check)
        controller.stub(:displayable_check)
      end

      context "ログインユーザが管理者の場合" do
        before{login_user(admin_user)}
        it_behaves_like("アクセス権があるユーザのアクセス制限確認", :delete, :destroy){subject{delete :destroy, id: section.id}}
      end

      context "ログインユーザが一般ユーザの場合" do
        before do
          login_user(user)
        end
        it_behaves_like("アクセス権がないユーザのアクセス制限確認", :delete, :destroy){subject{delete :destroy, id: section.id}}
      end
    end
  end

  describe "action" do
    let(:current_user){create(:super_user, section: create(:section))}
    let(:section){create(:section)}
    before do
      login_user(current_user)
    end

    describe "GET index" do
      describe "正常系" do
        before do
          section # let
        end

        subject{get :index}

        context "ログインユーザが管理者の場合" do
          let(:sections){(1..20).map{create(:section)}}

          before do
            current_user.update!(authority: User.authorities[:admin])
            sections
          end
          
          it "200が返ること" do
            expect(subject).to be_success
          end

          it "indexがrenderされること" do
            expect(subject).to render_template("index")
          end

          it "@sectionsに所属を全件取得し、ページネーションしてセットされていること" do
            get :index, page: 2
            expect(assigns[:sections]).to match_array(Section.page(2))
          end
        end

        context "ログインユーザが管理者以外の場合" do
          before do
            current_user.update!(authority: User.authorities[:editor])
          end

          it "200が返ること" do
            expect(subject).to be_success
          end

          it "showがrenderされること" do
            expect(subject).to render_template("show")
          end

          it "showが呼ばれること" do
            controller.should_receive(:show)
            subject
          end
        end
      end
    end

    describe "GET show" do
      describe "正常系" do
        let(:users){(1..10).map{create(:editor_user, section_id: section.id)}}
        let(:groups){(1..10).map{create(:user_group, section_id: section.id)}}
        
        before do
          other_section = create(:section)
          5.times do
            create(:editor_user, section_id: other_section.id)
            create(:user_group, section_id: other_section.id)
          end
        end

        subject{xhr :get, :show, id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "showがrenderされること" do
          expect(subject).to render_template("show")
        end

        context "@usersの検証" do
          it "@usersにsectionに登録されているユーザがセットされること" do
            subject
            expect(assigns[:users]).to match_array(users[0, UserMaintenance::SectionsController::SHOW_LIST_PER])
          end

          it "@usersはページネーションしていること" do
            xhr :get, :show, id: section.id, user_page: 2
            per = UserMaintenance::SectionsController::SHOW_LIST_PER
            expect(assigns[:users]).to match_array(users[per, per])
          end
        end

        context "@user_groupsの検証" do
          it "@user_groupsにsectionに登録されているグループがセットされること" do
            subject
            expect(assigns[:user_groups]).to match_array(groups[0, UserMaintenance::SectionsController::SHOW_LIST_PER])
          end

          it "@user_groupsはページネーションしていること" do
            xhr :get, :show, id: section.id, group_page: 2
            per = UserMaintenance::SectionsController::SHOW_LIST_PER
            expect(assigns[:user_groups]).to match_array(groups[per, per])
          end
        end
      end
    end

    describe "GET new" do
      describe "正常系" do
        subject{get :new}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "newがrenderされること" do
          expect(subject).to render_template("new")
        end

        it "@sectionにSectionの新規インスタンスがセットされること" do
          subject
          expect(assigns[:section]).to be_a_new(Section)
        end
      end
    end

    describe "GET edit" do
      before do
        #let call
        section
      end

      describe "正常系" do
        subject{get :edit, id: section.id}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "editがrenderされること" do
          expect(subject).to render_template("edit")
        end
      end
    end

    describe "POST create" do
      describe "正常系" do
        let(:section_params){{name: "松江市"}}
        subject {post :create, section: section_params}

        context "バリデーションに成功した場合" do
          it "Sectionレコードが追加されること" do
            expect{subject}.to change(Section, :count).by(1)
          end

          it "showにリダイレクトすること" do
            expect(subject).to redirect_to(section_path(assigns[:section]))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.create_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:section_params){{name: ""}}
        subject {post :create, section: section_params}

        context "バリデーションに失敗した場合" do
          it "レコードが追加されないこと" do
            expect{subject}.to change(Section, :count).by(0)
          end

          it "newがrenderされること" do
            expect(subject).to render_template(:new)
          end
        end
      end
    end

    describe "PATCH update" do
      before do
        #let call
        section
      end

      describe "正常系" do
        let(:section_params){{id: section.id, name: "松江市"}}
        subject {patch :update, id: section.id, section: section_params}

        context "バリデーションに成功した場合" do
          it "更新されていること" do
            subject
            expect(assigns[:section]).to eq(Section.new(section_params))
          end

          it "showにリダイレクトすること" do
            expect(subject).to redirect_to(section_path(section))
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.update_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:section_params){{name: ""}}
        subject {patch :update, id: section.id, section: section_params}

        context "バリデーションに失敗した場合" do
          it "editがrenderされること" do
            expect(subject).to render_template(:edit)
          end
        end
      end
    end

    describe "GET destroy" do
      before do
        #let call
        section
      end

      subject{delete :destroy, id: section.id}

      describe "正常系" do
        it "レコードが１件削除されること" do
          expect{subject}.to change(Section, :count).by(-1)
        end

        it "indexへリダイレクトされること" do
          expect(subject).to redirect_to(sections_path)
        end

        it "flash[:notice]がセットされること" do
          subject
          expect(flash[:notice]).to eq(I18n.t("notices.destroy_after"))
        end
      end

      describe "異常系" do
        context "削除できないデータの場合" do
          before{Section.any_instance.stub(:destroyable?){false}}

          it "flashをセットしてindexにリダイレクトすること" do
            expect(subject).to redirect_to(sections_path)
          end

          it "flashがセットされること" do
            msg = I18n.t("user_maintenance.sections.destroy.can_not_destroy")
            subject
            expect(flash[:alert]).to eq(msg)
          end
        end
      end
    end
  end

  describe "private" do
    let(:current_user){create(:editor_user)}
    let(:section){create(:section)}
    before do
      controller.stub(:current_user){current_user}
    end

    describe "section_params" do
      let(:valid_params){{"name" => "section"}}
      let(:invalid_params){valid_params.merge(test: "test")}
      subject{controller.send(:section_params)}
      before do
        controller.params[:section] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params.stringify_keys)
      end
    end
  end
end
