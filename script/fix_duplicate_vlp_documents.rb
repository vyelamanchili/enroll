people = Person.all.select do |person|
  next if person.consumer_role.nil?
  person.consumer_role.vlp_documents.length > 1
end

people.each do |person|
  begin
    documents = person.consumer_role.vlp_documents.clone
    puts "BEFORE Person id #{person.id}. Number of documents #{documents.length}"
    documents.uniq!
    person.consumer_role.vlp_documents = documents
    person.save!
    person.reload
    puts "AFTER  Person id #{person.id}. Number of documents #{person.consumer_role.vlp_documents.length}"
  rescue Exception => e
    puts "Error: person id #{person.id}" + e.message
  end
end


