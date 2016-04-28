namespace :dashboard do
  desc "seed for dashboard"
  task :seed => :environment do 
    event_topics = ["individual_initial_enrollments", 'auto_renewal', 'added_family_member', 'shop_coverage_terminated', 'shop_purchase_coverage']
    event_count = 535
    min_start_at = Time.new(2015, 11, 1, 0, 0, 0).to_i
    max_end_at = Time.new(2016, 1, 31, 23, 59, 59).to_i

    (1..event_count).each do |i|
      topic = event_topics.sample
      rand(1..10).times.each do |j|
        time = Time.at(rand(min_start_at..max_end_at))
        Analytics::AggregateEvent.increment_time( 
                                                 subject: topic,
                                                 moment: time
                                                ) 
        puts "#{topic}: at #{time.to_s}"
      end
    end
  end
end
