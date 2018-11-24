def get_crossfit_mainsite(as_of_date)
  puts "https://www.crossfit.com/workout/"
  
  # Get the JSON feed
  todays_date = Date.today.to_s
  feed_filename = '_feeds/crossfit-mainsite-'+todays_date+'.json'
  if !File.exist? feed_filename
    url = 'https://www.crossfit.com/workout/?page=1'
    headers = {
                "User-Agent" => $agents.sample, 
                "Accept" => "application/json, text/javascript, */*; q=0.01",
                "X-Requested-With" => 'XMLHttpRequest', 
                "Referer" => 'https://www.crossfit.com/workout/'
              }
    json = HTTParty.get(url, {:format=>'plain', headers: headers})
    File.open(feed_filename, 'w+') do |file|
      file.puts json
    end
  end

  posts = []
  # Process html
  if File.exist? feed_filename
    bits = File.read(feed_filename)
    data = JSON.parse(bits)
    data['wods'].each do |post|
      title = 'Mainsite WOD: ' + post['title']
      url = 'https://www.crossfit.com' + post['url']
      post_date = post['publishedOn'].split('T')[0]
      post = {
        'snark' => '',
        'title' => title.strip,
        'url' => url.strip,
        'date' => post_date,
        'source' => 'CrossFit Mainsite'
      }
      if as_of_date == nil or as_of_date == post_date
        posts.push(post)
      end
    end
  end
  return posts
end