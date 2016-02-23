class Users::SessionsController < Devise::SessionsController
  def create
    cookies.delete :session_timeout
    super
  end
end
