def get_crossfit_journal(as_of_date)
  puts "https://journal.crossfit.com"
  # Get the JSON feed
  todays_date = Date.today.to_s
  feed_filename = '_feeds/crossfit-journal-'+todays_date+'.json'
  if !File.exist? feed_filename
    url = 'https://journal.crossfit.com/media-api/api/v1/media/journal?sort=-publishingDate&per-page=18&page=1'
    json = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => $agents.sample}})
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