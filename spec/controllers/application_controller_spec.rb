require 'spec_helper'

describe ApplicationController do
  describe "admin_required" do
    subject{controller.send(:admin_required)}

    context "ログインしていない場合" do
      before{controller.stub(:user_signed_in?){false}}

      it "flash[:alert]をセットしてトップページにリダイレクトすること" do
        msg = I18n.t("alerts.can_not_access")
        controller.should_receive(:redirect_to).with(root_path, alert: msg)
        subject
      end
    end

    context "ログインしている場合で、ログインユーザが管理者以外の場合" do
      let(:user){create(:editor_user)}
      before do
        controller.stub(:user_signed_in?){true}
        controller.stub(:current_user){user}
        user.stub(:admin?){false}
      end

      it "flash[:alert]をセットしてトップページにリダイレクトすること" do
        msg = I18n.t("alerts.can_not_access")
        controller.should_receive(:redirect_to).with(root_path, alert: msg)
        subject
      end
    end
  end
end
