require 'spec_helper'

describe Vdb::Templates::ElementsController do
  describe "フィルタ" do
    describe "authenticate_user!" do
      before do
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:template_operator_check).and_return(true)
        controller.stub(:set_breadcrumbs).and_return(true)
      end

      shared_examples_for "未ログイン時のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、ログイン画面が表示されること" do
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      shared_examples_for "ログイン時のアクセス制限"  do |met, act|
        before{ login_user }
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(new).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, :only => [:new]
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :new) {before{get :new}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :new) {before{get :new}}
      end
    end

    describe "#template_operator_check" do
      before do
        controller.stub(:authenticate_user!).and_return(true)
        controller.stub(:set_template).and_return(true)
        controller.stub(:template_accessible_check).and_return(true)
        controller.stub(:set_breadcrumbs).and_return(true)
      end

      shared_examples_for "異なる所属のユーザがアクセスした場合のアクセス制限" do |met, act|
        before do
          login_user
          user = create(:editor_user)
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたときサービス一覧画面が表示されること" do
          expect(response).to redirect_to(services_path)
        end
      end

      shared_examples_for "データ登録者がアクセスした場合のアクセス制限" do |met, act|
        before do
          user = login_user(create(:editor_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたときサービス一覧画面が表示されること" do
          expect(response).to redirect_to(services_path)
        end
      end

      shared_examples_for "管理者がアクセスした場合のアクセス制限"  do |met, act|
        before do
          user = login_user(create(:super_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      shared_examples_for "所属管理者がアクセスした場合のアクセス制限"  do |met, act|
        before do
          user = login_user(create(:section_manager_user))
          service = create(:service, section_id: user.section_id)
          template = create(:template, service_id: service.id)
          controller.instance_eval{ @template = template }
        end

        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          (response.body == "ok").should be_true
        end
      end

      controller do
        %w(new).each do |act|
          define_method(act) do
            render text: "ok"
          end
        end
      end

      before do
        @routes.draw do
          resources :anonymous, :only => [:new]
        end
      end

      context "他の所属のユーザの場合" do
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
      end

      context "データ登録者の場合" do
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
      end

      context "管理者の場合" do
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
      end

      context "所属管理者の場合" do
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :new) {before{get :new}}
      end
    end
  end

  describe "アクション" do
    let(:service) { create(:service, section_id: @user.section_id) }
    let(:template) { create(:template, user_id: @user.id, service: service) }

    before do
      @user = login_user
    end

    describe "GET new" do
      before do
        get :new, template_id: template.id, use_route: :vdb
      end

      it "新しいElementインスタンスを作成していること" do
        expect(assigns[:element]).to be_a_new(Element)
      end

      it "newをrenderしていること" do
        expect(response).to render_template(:new)
      end
    end
  end
end
