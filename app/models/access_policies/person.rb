module AccessPolicies
  class Person
    attr_accessor :user, :controller

    def initialize(user, controller)
      @user = user
      @controller = controller
    end

    def authorize_agent_access_to_family(person_id)
      agent_person = user.person
      if agent_person
        if user.has_hbx_staff_role? || user.has_csr_subrole?
          return true
        elsif user.has_assister_role?
          return true if agent_person.assister_role.allowed_to_access person_id
        elsif user.has_cac_subrole?
          return true if agent_person.csr_role.allowed_to_access person_id
        elsif user.has_broker_role?
          broker_agency_profile_id = agent_person.broker_role.broker_agency_profile_id
          broker_agency = BrokerAgencyProfile.find(broker_agency_profile_id)
          return true if broker_agency.can_access_person_id person_id
        end
      end
      controller.security_exception
      return false         
    end
  end
end


      
  
