def get_news(feed_url,source,process_date=nil,source_category=nil)
  puts feed_url

  # Recent
  todays_date = Date.today.to_s
  feed_id = feed_url.split('/')[2].gsub('.com','').gsub('www.','')
  # Get feed
  feed_filename = '_feeds/'+feed_id+'-'+todays_date+'.xml'
  if !File.exist? feed_filename
    headers = {
                "User-Agent" => $agents.sample, 
                "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
              }
    xml = HTTParty.get(feed_url, {:format=>'plain', headers: headers, default_timeout: 10})
    File.open(feed_filename, 'w+') do |file|
      file.puts xml
    end
  end
  # Process feed
  posts = []
  if File.exist? feed_filename
    doc = File.open(feed_filename) { |f| Nokogiri::XML(f) }
    if doc
      doc.css('item').each do |item|
        # Post title
        title = item.css('title').first.content
        # Process categories
        has_cat = true
        if source_category != nil
          has_cat = false
          categories = item.css('category')
          if categories and categories.length > 0
            categories.each do |post_category|
              has_cat = true if source_category == post_category.content
            end
          end
        end
        next unless has_cat == true
        # Post date
        post_date = DateTime.parse(item.css('pubDate').first.content).to_s.split('T')[0]
        # Post URL
        url = item.css('link').first.content
        # Skip posts missing a title
        next if title and title == ''
        title.gsub!("\n",' ')
        post = {
          'snark' => '',
          'title' => title.strip,
          'url' => url.strip,
          'date' => post_date,
          'source' => source
        }
        if process_date == nil or process_date == post_date
          puts "\t" + title
          posts.push(post)
        end
      end
    end
  end
  return posts
end