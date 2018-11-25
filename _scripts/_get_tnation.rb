#_get_tnation.rb

def get_tnation(as_of_date) 
  puts url = 'https://www.t-nation.com/all-articles?order=published_at+desc'

  todays_date = Date.today.to_s
  feed_filename = '_html/t-nation-'+todays_date+'.html'

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
      doc.css("div.articleSearchPage").each do |article|
        url = 'https://www.t-nation.com' + article.css('a')[0]['href']
        title = article.css('a')[0].text
        byline_date = article.css('h2.byline-date').text.split('|')[1].strip
        if byline_date == "Today"
          article_date = Date.today
        elsif byline_date == "Yesterday"
          article_date = Date.today-1
        else
          byline_date
          parts = byline_date.split('/')
          mm = parts[0].to_i
          dd = parts[1].to_i
          yy = parts[2].to_i+2000
          article_date = DateTime.new(yy,mm,dd)
        end
        post_date = article_date.to_s.split('T')[0]
        post = {
          'snark' => '',
          'title' => title.strip,
          'url' => url.strip,
          'date' => post_date,
          'source' => 'T-Nation'
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