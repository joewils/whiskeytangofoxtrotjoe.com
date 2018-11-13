def get_news(feed_url,source,process_date=nil,source_category=nil)
  puts feed_url
  # User Agents
  agents = [
    'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1',
    'Mozilla/5.0 (Windows NT 6.2; rv:22.0) Gecko/20130405 Firefox/23.0',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko',
    'Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A',
    'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1'
  ]
  # Recent
  todays_date = Date.today.to_s
  feed_id = feed_url.split('/')[2].gsub('.com','').gsub('www.','')
  # Get feed
  feed_filename = '_feeds/'+feed_id+'-'+todays_date+'.xml'
  if !File.exist? feed_filename
    xml = HTTParty.get(feed_url, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
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
        post = {
          'snark' => '',
          'title' => title.strip,
          'url' => url.strip,
          'date' => post_date,
          'source' => source
        }
        if process_date == nil or process_date == post_date
          posts.push(post)
        end
      end
    end
  end
  return posts
end