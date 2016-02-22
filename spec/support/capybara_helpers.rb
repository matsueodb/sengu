module CapybaraHelpers
  include Warden::Test::Helpers
  Warden.test_mode!

  def login_user(user=nil)
    user = create(:super_user) unless user
    login_as(user, scope: :user)
    user
  end

  def wait_until(offset=0)
    if block_given?
      start = Time.now
      while true
        break if yield
        if Time.now > start + 5.seconds
          fail "Whizboo didn't happen."
        end
        sleep 0.1
      end
    end
    sleep offset
  end

  def set_webkit_window_size(width, height)
    page.driver.resize_window(width, height)
  end
end
