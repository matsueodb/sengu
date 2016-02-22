require 'spec_helper'

describe Templates::SettingsController do
  let(:section){create(:section)}
  let(:current_user){create(:section_manager_user, section_id: section.id)}
  let(:service){create(:service, section_id: section.id)}
  let(:template){create(:template, user_id: current_user.id, service_id: service.id)}
  describe "filter" do
    let(:filters){[
      :authenticate_user!, :set_template, :template_accessible_check,
      :template_operator_check, :accessible_check
    ]}
    controller do
      [
        :set_confirm_entries, :update_set_confirm_entries
      ].each do |act|
        define_method(act) do
          render text: "ok"
        end
      end
    end

    before do
      @routes.draw do
        resources :anonymous, only: [] do
          collection do
            get :set_confirm_entries
            post :update_set_confirm_entries
          end
        end
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
        filters.reject{|f|f == :authenticate_user!}.each do |f|
          controller.stub(f)
        end
      end

      context "未ログイン状態" do
        it_behaves_like("未ログイン時のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("未ログイン時のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end

      context "ログイン状態" do
        it_behaves_like("ログイン時のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("ログイン時のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end
    end

    describe "#set_template" do
       before do
        filters.reject{|f|f == :set_template}.each do |f|
          controller.stub(f)
        end
      end

      shared_examples_for("インスタンス変数の確認") do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、@templateがセットされること" do
          subject
          expect(assigns[:template]).to eq(template)
        end
      end

      it_behaves_like("インスタンス変数の確認", :get, :set_confirm_entries) {subject{get :set_confirm_entries, template_id: template.id}}
      it_behaves_like("インスタンス変数の確認", :post, :update_set_confirm_entries) {subject{post :update_set_confirm_entries, template_id: template.id}}
    end

    describe "#template_accessible_check" do
      before do
        login_user(current_user)
        filters.reject{|f|f == :template_accessible_check}.each do |f|
          controller.stub(f)
        end

        temp = template
        controller.instance_eval do
          @template = temp
        end
      end

      shared_examples_for "アクセス権がない場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、サービス一覧が表示されること" do
          expect(subject).to redirect_to(services_path)
        end

        it "#{met.upcase} #{act}にアクセスしたとき、flash[:alert]がセットされること" do
          subject
          expect(flash[:alert]).to eq(I18n.t("alerts.can_not_access"))
        end
      end

      shared_examples_for "アクセス権がある場合のアクセス制限" do |met, act|
        it "#{met.upcase} #{act}にアクセスしたとき、okが返ること" do
          subject
          expect(response.body).to eq("ok")
        end
      end


      context "ログインユーザがテンプレートのサービスに割り当てられた所属のユーザの場合" do
        it_behaves_like("アクセス権がある場合のアクセス制限", :get, :set_confirm_entries) {subject{get :set_confirm_entries, template_id: template.id}}
        it_behaves_like("アクセス権がある場合のアクセス制限", :post, :update_set_confirm_entries) {subject{post :update_set_confirm_entries, template_id: template.id}}
      end

      context "ログインユーザがテンプレートのサービスに割れ当てられた所属のユーザではない場合" do
        before{current_user.update!(section_id: create(:section).id)}

        context "テンプレートにグループが割り当てられていない場合" do
          before{template.update!(user_group_id: nil)}

          it_behaves_like("アクセス権がない場合のアクセス制限", :get, :set_confirm_entries) {subject{get :set_confirm_entries, template_id: template.id}}
          it_behaves_like("アクセス権がない場合のアクセス制限", :post, :update_set_confirm_entries) {subject{post :update_set_confirm_entries, template_id: template.id}}
        end

        context "テンプレートにグループが割り当てられている場合" do
          let(:user_group){create(:user_group, section_id: section.id)}
          before{template.update!(user_group_id: user_group.id)}

          context "ログインユーザがグループのメンバーの場合" do
            before{user_group.users << current_user}

            it_behaves_like("アクセス権がある場合のアクセス制限", :get, :set_confirm_entries) {subject{get :set_confirm_entries, template_id: template.id}}
            it_behaves_like("アクセス権がある場合のアクセス制限", :post, :update_set_confirm_entries) {subject{post :update_set_confirm_entries, template_id: template.id}}
          end

          context "ログインユーザがグループのメンバーではない場合" do
            it_behaves_like("アクセス権がない場合のアクセス制限", :get, :set_confirm_entries) {subject{get :set_confirm_entries, template_id: template.id}}
            it_behaves_like("アクセス権がない場合のアクセス制限", :post, :update_set_confirm_entries) {subject{post :update_set_confirm_entries, template_id: template.id}}
          end
        end
      end
    end

    describe "#template_operator_check" do
      before do
        filters.reject{|f|f == :template_operator_check}.each do |f|
          controller.stub(f)
        end
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

      context "他の所属のユーザの場合" do
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("異なる所属のユーザがアクセスした場合のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end

      context "データ登録者の場合" do
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("データ登録者がアクセスした場合のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end

      context "管理者の場合" do
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("管理者がアクセスした場合のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end

      context "所属管理者の場合" do
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :get, :set_confirm_entries) {before{get :set_confirm_entries}}
        it_behaves_like("所属管理者がアクセスした場合のアクセス制限", :post, :update_set_confirm_entries) {before{post :update_set_confirm_entries}}
      end
    end
  end

  describe "action" do
    before do
      login_user(current_user)
    end

    describe "GET set_confirm_entries" do
      let(:it_line){create(:input_type_line)}
      let(:it_date){create(:input_type_dates)}
      let(:elements){(1..5).map{create(:element, input_type_id: it_line.id, template_id: template.id)}}

      before do
        elements # let
        # other_elements 以下のelementsは@elementsに含まれないダミー
        create(:element, input_type_id: it_date.id, template_id: template.id)
        create(:element, input_type_id: it_line.id, template_id: 0)
      end

      subject{get :set_confirm_entries, template_id: template.id}
      describe "正常系" do
        it "200が返ること" do
          expect(subject).to be_success
        end

        it "set_confirm_entriesがrenderされること" do
          expect(subject).to render_template("set_confirm_entries")
        end

        context "@elementsの検証" do
          it "テンプレートに登録されている１行入力のエレメントが返ること" do
            subject
            expect(assigns[:elements]).to eq(elements)
          end
        end
      end
    end

    describe "POST update_set_confirm_entries" do
      let(:it_line){create(:input_type_line)}
      let(:selected_els){(1..3).map{create(:element, input_type_id: it_line.id, template_id: template.id)}}
      let(:select_els){[
          selected_els[0],
          create(:element, input_type_id: it_line.id, template_id: template.id)
        ]}

      subject{post :update_set_confirm_entries, template_id: template.id, element_ids: select_els.map(&:id)}

      describe "正常系" do
        it "set_confirm_entriesにリダイレクトすること" do
          expect(subject).to redirect_to(set_confirm_entries_template_settings_path(template_id: template.id))
        end

        it "flash[:notice]がセットされること" do
          subject
          msg = I18n.t("templates.settings.update_set_confirm_entries.success")
          expect(flash[:notice]).to eq(msg)
        end

        it "params[:element_ids]で送られたレコードのconfirm_entryがtrueとなっていること" do
          subject
          Element.find(select_els.map(&:id)).each do |el|
            expect(el.confirm_entry).to be_true
          end
        end

        it "params[:element_ids]で送られていないレコードのconfirm_entryがfalseとなっていること" do
          subject
          Element.find([selected_els[1].id, selected_els[2].id]).each do |el|
            expect(el.confirm_entry).to be_false
          end
        end
      end

      describe "異常系" do
        context "例外発生時" do
          before do
            Template.any_instance.stub(:elements).and_raise
          end

          it "更新ができていないこと" do
            expect{subject}.to_not change{Element.find(selected_els[1]).confirm_entry}.from(true).to(false)
          end

          it "flash[:alert]がセットされること" do
            subject
            msg = I18n.t("templates.settings.update_set_confirm_entries.failed")
            expect(flash[:alert]).to eq(msg)
          end

          it "set_confirm_entriesにリダイレクトすること" do
            expect(subject).to redirect_to(set_confirm_entries_template_settings_path(template_id: template.id))
          end
        end
      end
    end
  end
end
