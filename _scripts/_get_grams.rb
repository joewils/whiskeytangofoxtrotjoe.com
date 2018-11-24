def get_grams(ig_user,as_of_date)
  puts "https://www.instagram.com/"+ig_user

  # Get IG HTML
  todays_date = Date.today.to_s
  filename = '_html/instagram-'+ig_user+'-'+todays_date+'.html'

  if !File.exist? filename
    sleep(rand(1..3)) # play nice
    # Craft Instagram post URL
    url = 'https://www.instagram.com/'+ig_user+'/?hl=en'
    html = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => $agents.sample}})
    if html.response.code.to_s == '200'
      File.open(filename, 'w+') do |file|
        file.puts html
      end
    end
  end

  # Process HTML
  posts = []
  if File.exist? filename
    doc = File.open(filename) { |f| Nokogiri::XML(f) }
    if doc
      # Do something
      doc.css('script').each do |script|
        content = script.content
        if content.include? "window._sharedData"
          # Extract the latest posts
          pieces = content.split('window._sharedData = ')
          if pieces.length == 2
            meat = pieces[1].gsub('};','}')
            json = JSON.parse(meat)
            # Archive JSON data
            filename = '_html/instagram-'+ig_user+'-'+todays_date+'.json'
            File.open(filename, 'w+') do |file|
              file.puts JSON.pretty_generate(json)
            end
            #video_timeline = json['entry_data']['ProfilePage'][0]['graphql']['user']['edge_felix_video_timeline']
            media_timeline = json['entry_data']['ProfilePage'][0]['graphql']['user']['edge_owner_to_timeline_media']['edges']
            media_timeline.each do |potatoe|
              # Build target URL from shortcode
              shortcode = potatoe['node']['shortcode']
              url = 'https://www.instagram.com/p/'+shortcode+'/?hl=en'
              # Build random length title from caption
              caption = potatoe['node']['edge_media_to_caption']['edges'][0]['node']['text']
              caption.gsub!("\n",' ')
              title = (caption[0, 100]).strip + "..."
              # Build date from epoch timestamp
              timestamp = potatoe['node']['taken_at_timestamp']
              post_date = Time.at(timestamp).to_datetime.to_s.split('T')[0]
              # Skip post unless 
              # Build post
              post = {
                'snark' => '',
                'title' => strip_emoji(title),
                'url' => url.strip,
                'date' => post_date,
                'source' => '@'+ig_user
              }
              if as_of_date == nil or as_of_date == post_date
                posts.push(post)
                puts "\t" + post['title']
              end
            end # media_timeline.each
          end # pieces
        end # content.include?
      end # doc.css
    end # if doc
  end # File.exist?
  return posts
end

# https://gist.github.com/adamlwatson/9623703
def strip_emoji ( str )
  str = str.force_encoding('utf-8').encode
  clean_text = ""

  # emoticons  1F601 - 1F64F
  regex = /[\u{1f600}-\u{1f64f}]/
  clean_text = str.gsub regex, ''

  #dingbats 2702 - 27B0
  regex = /[\u{2702}-\u{27b0}]/
  clean_text = clean_text.gsub regex, ''

  # transport/map symbols
  regex = /[\u{1f680}-\u{1f6ff}]/
  clean_text = clean_text.gsub regex, ''

  # enclosed chars  24C2 - 1F251
  regex = /[\u{24C2}-\u{1F251}]/
  clean_text = clean_text.gsub regex, ''

  # symbols & pics
  regex = /[\u{1f300}-\u{1f5ff}]/
  clean_text = clean_text.gsub regex, ''

  return clean_text
end