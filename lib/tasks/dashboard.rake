namespace :dashboard do
  desc "seed for dashboard"
  task :seed => :environment do 
    event_topics = ["individual_initial_enrollments", 'auto_renewal', 'added_family_member', 'shop_coverage_terminated', 'shop_purchase_coverage']
    event_count = 135
    min_start_at = Time.new(2015, 11, 1, 0, 0, 0).to_i
    max_end_at = Time.new(2016, 1, 31, 23, 59, 59).to_i

    (1..event_count).each do |i|
      Analytics::AggregateEvent.increment_time( 
                                               topic: event_topics.sample,
                                               moment: Time.at(rand(min_start_at..max_end_at))
                                              ) 
    end
  end
end
