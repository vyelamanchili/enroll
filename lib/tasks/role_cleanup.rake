namespace :access_policies do
  desc 'Migrate help requests'
  task :role_migrate => :environment do
  	assisters = Person.exists(assister_role: true).exists(user: true).select{|p|p.inbox.messages.count > 1}

    assisters.each{|a|
      authorized = []
      a.inbox.messages.each{|m|
        if m && m[:body]
          match = m[:body].match(/person_id=(\w+)\&/)
          if match
      	    authorized << match[1] 
      	  end 
        end
      }
      puts "#{a.id}, #{a.person.first_name}, #{a.person.last_name}, #{authorized.uniq.inspect}"
      a.update_attributes!(authorized_to_access: authorized.uniq) 
    };nil


    cacs = Person.exists(csr_role: true).exists(user: true).where(:'csr_role.cac' => true).select{|p|p.inbox.messages.count > 1}

    cacs.each{|cac|
      authorized = []
      cac.inbox.messages.each{|m|
        if m && m[:body]
          match = m[:body].match(/person_id=(\w+)\&/)
          if match
    	      authorized << match[1] 
    	    end
        end  
      }
      puts "#{cac.id}, #{cac.person.first_name}, #{cac.person.last_name}, #{authorized.uniq.inspect}"
      a.update_attributes!(authorized_to_access: authorized.uniq) 
    };nil

  end
end