module LoginHelpers
  def login_user(user=nil)
    user = create(:super_user) unless user
    @request.env['devise.mapping'] = Devise.mappings[:admin]
    sign_in user
    return user
  end

  def logout_user(user)
    sign_out user
  end
end
