#_get_tierthreetactical.rb

def get_tierthreetactical(as_of_date) 
  puts url = 'http://www.tierthreetactical.com/category/pt/'

  todays_date = Date.today.to_s
  feed_filename = '_html/tierthreetactical-pt-'+todays_date+'.html'

  if !File.exist? feed_filename
    html = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => $agents.sample}})
    File.open(feed_filename, 'w+') do |file|
      file.puts html
    end
  end

  posts = []
  # Process html
  if File.exist? feed_filename
    bits = File.read(feed_filename)
    doc = Nokogiri::HTML(bits)
    if doc
      # Hero articles
      doc.css("div.td-meta-info-container").each do |meta|
        title = meta.css("h3").text
        url = meta.css("h3").css("a")[0]['href']
        post_date = DateTime.parse(meta.css("time").text).to_s.split('T')[0]
        post = {
          'snark' => '',
          'title' => title.strip,
          'url' => url.strip,
          'date' => post_date,
          'source' => 'Tier Three Tactical'
        }
        if as_of_date == nil or as_of_date == post_date
          puts "\t" + post['title']
          posts.push(post)
        end
      end
    end
  end

  return posts
end
