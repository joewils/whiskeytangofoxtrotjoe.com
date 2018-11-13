def get_crossfit_mainsite(as_of_date)
  puts "https://www.crossfit.com/workout/"
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
  # Get the JSON feed
  todays_date = Date.today.to_s
  feed_filename = '_feeds/crossfit-mainsite-'+todays_date+'.json'
  if !File.exist? feed_filename
    url = 'https://www.crossfit.com/workout/?page=1'
    headers = {
                "User-Agent" => agents.sample, 
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