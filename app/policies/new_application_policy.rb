# Creator: Lovell McIlwain
# Date: 2016-02-09
# New base policy inheritence. The original application policy is too bulky and should not be used for new policies without good reason.
class NewApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
  
end