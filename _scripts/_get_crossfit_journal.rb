def get_crossfit_journal(as_of_date)
  puts "https://journal.crossfit.com"
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
  feed_filename = '_feeds/crossfit-journal-'+todays_date+'.json'
  if !File.exist? feed_filename
    url = 'https://journal.crossfit.com/media-api/api/v1/media/journal?sort=-publishingDate&per-page=18&page=1'
    json = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
    File.open(feed_filename, 'w+') do |file|
      file.puts json
    end
  end
  posts = []
  # Process html
  if File.exist? feed_filename
    bits = File.read(feed_filename)
    data = JSON.parse(bits)
    data.each do |post|
      title = post['title']
      url = 'https://journal.crossfit.com/article/' + post['slug']
      post_date = DateTime.parse(post['publishedOn']).to_s.split('T')[0]
      post = {
        'snark' => '',
        'title' => title.strip,
        'url' => url.strip,
        'date' => post_date,
        'source' => 'CrossFit Journal'
      }
      if as_of_date == nil or as_of_date == post_date
        posts.push(post)
      end
    end
  end
  return posts
end