feins = [] #set feins for employers to who's CVs are to be generated

@dir_name = "employer_cv.v2"
Dir.mkdir(@dir_name) unless File.exists?(@dir_name)

XML_NS = "http://openhbx.org/api/terms/1.0"

def write(payload, file_name)
  File.open(File.join(@dir_name, "#{file_name}.xml"), 'w') do |f|
    f.puts payload
  end
end

views = Rails::Application::Configuration.new(Rails.root).paths["app/views"]
views_helper = ActionView::Base.new views
include EventsHelper

feins.each do |fein|
  begin
    employer_profile = Organization.where(:fein => fein.gsub("-", "")).first.employer_profile

    cv_xml = views_helper.render file: File.join(Rails.root, "/app/views/events/v2/employers/updated.xml.haml"), :locals => {employer: employer_profile}
    write(cv_xml, fein)
  rescue => e
    puts "Error FEIN #{fein} #{e.message}\n " + e.backtrace.to_s
  end
end