def get_shape(as_of_date)
  puts "https://www.shape.com/fitness"
  # Get the JSON feed
  todays_date = Date.today.to_s
  filename = '_html/shape-'+todays_date+'.html'
  if !File.exist? filename
    url = 'https://www.shape.com/fitness'
    html = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => $agents.sample}})
    File.open(filename, 'w+') do |file|
      file.puts html
    end
  end
  posts = []
  # 
  # Process json
  if File.exist? filename
    bits = File.read(filename)
    doc = Nokogiri::HTML(bits)
    items = doc.css('div.taxonomy-recent-item')
    items.each do |item|
      url = 'https://www.shapre.com' + item.css('a.taxonomy-recent-item__link')[0]['href']
      title = item.css('h3.taxonomy-recent-item__title').text
      time_ago = item.css('p.taxonomy-recent-item__time-ago').text
      if time_ago.include? 'hrs'
        article_date = Date.today
      elsif time_ago.include? 'days'
        bits = time_ago.split(' ')
        days_ago = bits[0]
        article_date = Date.today-days_ago.to_i
      end
      if article_date
        post_date = article_date.to_s.split('T')[0]
        post = {
          'snark' => '',
          'title' => title.strip,
          'url' => url.strip,
          'date' => post_date,
          'source' => 'Shape'
        }
        if as_of_date == nil or as_of_date == post_date
          puts "\t" + post['title']
          posts.push(post)
        end
      end # article_date
    end # items
  end
  return posts
end