Person.all.no_timeout.each do |c|
  if c.present? && c.consumer_role.present? && c.consumer_role.bookmark_url.present? && c.consumer_role.bookmark_url.include?("https://enroll.dchealthlink.com")
    link = c.consumer_role.bookmark_url.gsub("https://enroll.dchealthlink.com", '')
    c.consumer_role.update_attributes!(bookmark_url: link)
    p c.consumer_role.bookmark_url
  end
end
