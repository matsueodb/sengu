class Users::SessionsController < Devise::SessionsController
  def destroy
    ImportCSV.remove_user_dir(current_user.id)
    super
  end
end
