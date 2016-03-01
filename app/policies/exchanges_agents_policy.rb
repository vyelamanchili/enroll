=begin
Headless Policy for Exchanges::Agents controller.

Headless == No associated model

Ideally this policy should be namespaced under an exchanges folder. Pundit is weird about namespacing. Espcially when there isn't a model to reference.

Details:
Class name is derived from exchanges namespace and agents controller name.
Because there isnt a model, there isn't an object to authorize so this is why open struct is being used. To access the methods within this policy, you must use the policy syntax:
```
policy(:exchanges_agent).correct_role?
```

Looking at the code above:
:user parameter can be whatever name you want it to be. That paramter implies the user/person logged in. Be carefull to make sure that you use the correct naming or it will be confusing to the next person who reviews the code.

:exchanges_agents can also be whatever name you want it to be. THe parameter should be something that closely resembles the policy name since this is what is used outside of this policy to access the methods within it.

Reference: https://github.com/elabs/pundit#headless-policies
=end

class ExchangesAgentsPolicy < Struct.new(:user, :exchanges_agents)
  def correct_role?
    user.has_agent_role? || user.has_hbx_staff_role? || user.has_broker_role?
  end
end
