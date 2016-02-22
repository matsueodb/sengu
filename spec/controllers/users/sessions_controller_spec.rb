require 'spec_helper'

describe Users::SessionsController do
  let(:template) { create(:template, user_id: @user.id) }

  describe "POST create" do
    let(:login){"xbuwu23f"} # random
    let(:psw){"5affsyad"} # random
    let(:user){create(:editor_user, login: login, password: psw, password_confirmation: psw)}
    let(:user_params){{login: login, password: psw}}
    before do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user # let call
    end

    
    # NOTE: ログインについてはDevise GEMをそのまま使用しているため、簡単なテストのみを行う。
    subject{post :create, user: user_params}

    it "ログインができること" do
      subject
      expect(controller.current_user).to eq(user)
    end
  end

  describe "DELETE destroy" do
    before do
      @user = login_user
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    it "CSVのユーザディレクトリ削除をしていること" do
      expect(ImportCSV).to receive(:remove_user_dir)
      delete :destroy
    end

    # NOTE: ログアウトについてはDevise GEMをそのまま使用しているため、簡単なテストのみを行う。
    subject{delete :destroy, id: @user.id}

    it "ログアウトができること" do
      subject
      expect(controller.current_user).to be_nil
    end
  end
end

