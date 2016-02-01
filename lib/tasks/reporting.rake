namespace :reporting do
  desc "Denormalize the historic data, so we can build time dimensions"
  task :denormalize_historic_data => :environment do
    ReportSources::HbxEnrollmentStatistic.delete_all
    ReportSources::HbxEnrollmentStatistic.populate_historic_data!
  end

  desc "Use the denormalized historic data to populate the time dimensions"
  task :populate_time_dimensions => :environment do
    ReportSources::HbxEnrollmentStatistic.populate_time_dimensions!
  end

  desc "Denormalize and populate time dimentions in one go."
  task :denormalize_and_populate_historic_dimensions => :environment do
    Rake::Task["reporting:denormalize_historic_data"].invoke
    Rake::Task["reporting:populate_time_dimensions"].invoke
  end
end
