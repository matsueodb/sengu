require 'spec_helper'

describe Admin::RegularExpressionsController do
  describe "filter" do
    let(:regular_expression){create(:regular_expression)}
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
        controller.stub(:admin_required)
        controller.stub(:set_regular_expression)
        controller.stub(:set_regular_expression_list)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
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

    describe "#admin_required" do
      shared_examples_for "一般ユーザログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、トップページ画面が表示されること" do
          expect(subject).to redirect_to(root_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          msg = I18n.t("alerts.can_not_access")
          expect(flash[:alert]).to eq(msg)
        end
      end

      shared_examples_for "管理者ログイン時のアクセス制限" do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:authenticate_user!)
        controller.stub(:set_regular_expression)
        controller.stub(:set_regular_expression_list)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
      end

      context "一般ユーザログイン時" do
        before{login_user(create(:editor_user))}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("一般ユーザログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end

      context "管理者ログイン時" do
        before{login_user(create(:super_user))}
        it_behaves_like("管理者ログイン時のアクセス制限", :get, :index) {before{get :index}}
        it_behaves_like("管理者ログイン時のアクセス制限", :get, :new) {before{get :new}}
        it_behaves_like("管理者ログイン時のアクセス制限", :get, :edit) {before{get :edit, id: 1}}
        it_behaves_like("管理者ログイン時のアクセス制限", :get, :show) {before{get :show, id: 1}}
        it_behaves_like("管理者ログイン時のアクセス制限", :post, :create) {before{post :create}}
        it_behaves_like("管理者ログイン時のアクセス制限", :patch, :update) {before{patch :update, id: 1}}
        it_behaves_like("管理者ログイン時のアクセス制限", :delete, :destroy) {before{delete :destroy, id: 1}}
      end
    end

    describe "#set_regular_expression" do
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@regular_expressionがセットされていること" do
          expect(assigns[:regular_expression]).to eq(regular_expression)
        end
      end

      before do
        controller.stub(:authenticate_user!)
        controller.stub(:admin_required)
        controller.stub(:set_regular_expression_list)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
      end

      it_behaves_like("インスタンス変数の確認", :get, :show){before{get :show, id: regular_expression.id}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: regular_expression.id}}
      it_behaves_like("インスタンス変数の確認", :patch, :update){before{patch :update, id: regular_expression.id}}
      it_behaves_like("インスタンス変数の確認", :delete, :destroy){before{delete :destroy, id: regular_expression.id}}
    end

    describe "#set_regular_expression_list" do
      let(:regular_expressions){(1..21).map{create(:regular_expression)}.sort_by(&:id)}
      shared_examples_for "インスタンス変数の確認" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@regular_expressionがページネーションされてセットされていること" do
          expect(assigns[:regular_expressions]).to match_array(regular_expressions[10, 10])
        end
      end
      
      before do
        controller.stub(:authenticate_user!)
        controller.stub(:admin_required)
        controller.stub(:set_regular_expression)
        controller.stub(:editable_check)
        controller.stub(:destroyable_check)
        regular_expressions
      end

      it_behaves_like("インスタンス変数の確認", :get, :index){before{get :index, page: 2}}
      it_behaves_like("インスタンス変数の確認", :get, :new){before{get :new, page: 2}}
      it_behaves_like("インスタンス変数の確認", :get, :edit){before{get :edit, id: regular_expression.id, page: 2}}
    end

    describe "#editable_check" do
      shared_examples_for "編集できないデータのアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、index画面が表示されること" do
          expect(subject).to redirect_to(regular_expressions_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          msg = I18n.t("alerts.can_not_edit")
          expect(flash[:alert]).to eq(msg)
        end
      end

      shared_examples_for "編集できるデータのアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:authenticate_user!)
        controller.stub(:admin_required)
        controller.stub(:set_regular_expression)
        controller.stub(:set_regular_expression_list)
        controller.stub(:destroyable_check)
        re = regular_expression
        controller.instance_eval do
          @regular_expression = re
        end
      end

      context "editable==falseの場合" do
        before{regular_expression.update(editable: false)}
        it_behaves_like("編集できないデータのアクセス制限", :get, :edit){before{get :edit, id: regular_expression.id}}
        it_behaves_like("編集できないデータのアクセス制限", :patch, :update){before{patch :update, id: regular_expression.id}}
      end

      context "editable==trueの場合" do
        before{regular_expression.update(editable: true)}
        it_behaves_like("編集できるデータのアクセス制限", :get, :edit){before{get :edit, id: regular_expression.id}}
        it_behaves_like("編集できるデータのアクセス制限", :patch, :update){before{patch :update, id: regular_expression.id}}
      end
    end

    describe "#destroyable_check" do
      shared_examples_for "削除できないデータのアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、index画面が表示されること" do
          expect(subject).to redirect_to(regular_expressions_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          msg = I18n.t("alerts.can_not_destroy")
          expect(flash[:alert]).to eq(msg)
        end
      end

      shared_examples_for "削除できるデータのアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          expect(response.body).to eq("ok")
        end
      end

      before do
        controller.stub(:authenticate_user!)
        controller.stub(:admin_required)
        controller.stub(:set_regular_expression)
        controller.stub(:set_regular_expression_list)
        controller.stub(:editable_check)
        re = regular_expression
        controller.instance_eval do
          @regular_expression = re
        end
      end

      context "editable==falseの場合" do
        before{regular_expression.update(editable: false)}
        it_behaves_like("削除できないデータのアクセス制限", :delete, :destroy){before{delete :destroy, id: regular_expression.id}}
      end

      context "editable==trueの場合" do
        before{regular_expression.update(editable: true)}
        it_behaves_like("削除できるデータのアクセス制限", :delete, :destroy){before{delete :destroy, id: regular_expression.id}}
      end
    end
  end

  describe "action" do
    let(:current_user){create(:editor_user)}
    let(:regular_expression){create(:regular_expression)}
    before do
      controller.stub(:authenticate_user!)
      controller.stub(:admin_required)
      controller.stub(:set_regular_expression)
      controller.stub(:current_user){current_user}
      3.times do
        create(:regular_expression)
      end
    end

    describe "GET index" do
      describe "正常系" do
        before do
          regular_expression # let
        end

        subject{get :index}

        it "200が返ること" do
          expect(subject).to be_success
        end

        it "indexがrenderされること" do
          expect(subject).to render_template("index")
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

        it "@regular_expressionにRegularExpressionの新規インスタンスがセットされること" do
          subject
          expect(assigns[:regular_expression]).to be_a_new(RegularExpression)
        end
      end
    end

    describe "GET edit" do
      before do
        ug = regular_expression
        controller.instance_eval do
          @regular_expression = ug
        end
      end

      describe "正常系" do
        subject{get :edit, id: regular_expression.id}

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
        let(:regular_expression_params){{name: "数値", format: "^[0-9]+$", option: "i"}}
        subject {post :create, regular_expression: regular_expression_params}

        context "バリデーションに成功した場合" do
          it "RegularExpressionレコードが追加されること" do
            expect{subject}.to change(RegularExpression, :count).by(1)
          end

          it "regular_expressions/にリダイレクトすること" do
            expect(subject).to redirect_to(regular_expressions_path)
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.create_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:regular_expression_params){{name: "数値", format: "", option: "i"}}
        subject {post :create, regular_expression: regular_expression_params}

        context "バリデーションに失敗した場合" do
          it "レコードが追加されないこと" do
            expect{subject}.to change(RegularExpression, :count).by(0)
          end

          it "newがrenderされること" do
            expect(subject).to render_template(:new)
          end

          it "set_regular_expression_listが呼ばれること" do
            controller.should_receive(:set_regular_expression_list)
            subject
          end
        end
      end
    end

    describe "PATCH update" do
      before do
        ug = regular_expression
        controller.instance_eval do
          @regular_expression = ug
        end
      end

      describe "正常系" do
        let(:regular_expression_params){{id: regular_expression.id, name: "数値", format: "^[0-9]+$", option: "i"}}
        subject {patch :update, id: regular_expression.id, regular_expression: regular_expression_params}

        context "バリデーションに成功した場合" do
          it "更新されていること" do
            subject
            expect(assigns[:regular_expression]).to eq(RegularExpression.new(regular_expression_params))
          end

          it "indexにリダイレクトすること" do
            expect(subject).to redirect_to(regular_expressions_path)
          end

          it "flash[:notice]がセットされること" do
            subject
            msg = I18n.t("notices.update_after")
            expect(flash[:notice]).to eq(msg)
          end
        end
      end

      describe "異常系" do
        let(:regular_expression_params){{name: "数値", format: "", option: "i"}}
        subject {patch :update, id: regular_expression.id, regular_expression: regular_expression_params}

        context "バリデーションに失敗した場合" do
          it "editがrenderされること" do
            expect(subject).to render_template(:edit)
          end

          it "set_regular_expression_listが呼ばれること" do
            controller.should_receive(:set_regular_expression_list)
            subject
          end
        end
      end
    end

    describe "DELETE destroy" do
      before do
        ug = regular_expression
        controller.instance_eval do
          @regular_expression = ug
        end
      end

      subject{delete :destroy, id: regular_expression.id}

      describe "正常系" do
        it "レコードが１件削除されること" do
          expect{subject}.to change(RegularExpression, :count).by(-1)
        end

        it "indexへリダイレクトされること" do
          expect(subject).to redirect_to(regular_expressions_path)
        end

        it "flash[:notice]がセットされること" do
          subject
          expect(flash[:notice]).to eq(I18n.t("notices.destroy_after"))
        end
      end

      describe "異常系" do
        context "選択した入力値制限マスタを使用している項目がある場合" do
          before do
            create(:element, regular_expression: regular_expression)
          end

          it "indexへリダイレクトされること" do
            expect(subject).to redirect_to(regular_expressions_path)
          end

          it "flash[:alert]がセットされること" do
            subject
            expect(flash[:alert]).to eq(I18n.t("admin.regular_expressions.destroy.failed"))
          end
        end
      end
    end
  end

  describe "private" do
    let(:current_user){create(:editor_user)}
    let(:regular_expression){create(:regular_expression)}
    before do
      controller.stub(:current_user){current_user}
    end

    describe "regular_expression_params" do
      let(:valid_params){{"name" => "regular_expression"}}
      let(:invalid_params){valid_params.merge(test: "test")}
      subject{controller.send(:regular_expression_params)}
      before do
        controller.params[:regular_expression] = invalid_params
      end

      it "valid_paramsのみが残ること" do
        expect(subject).to eq(valid_params.stringify_keys)
      end
    end
  end
end
