# Creator: Lovell McIlwain
# Date: 2016-02-09
# Headless policy for the application controller
class ApplicationControllerPolicy < Struct.new(:user, :application_controller)
  
  def set_current_person?
    user.person && user.person.agent?
  end
  
end