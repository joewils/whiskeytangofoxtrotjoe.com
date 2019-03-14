require 'base64'
require 'front_matter_parser'
require 'json'
require 'news-api'
require 'yaml'

require_relative('_get_crossfit')
require_relative('_get_fitness')

$exclude_domains = 'fastcompany.com,ozbargain.com.au,online-tech-tips.com,pocket-lint.com,dailymail.co.uk,hospitalitynet.org,finance.yahoo.com,gizmodo.com.au,dealnews.com,sputniknews.com,technobuffalo.com,livejournal.com,indianexpress.com,windowscentral.com,marketwatch.com,androidcentral.com,businessinsider.com,prnewswire.com,9to5toys.com,hvper.com,businesswire.com,thehollywoodgossip.com,lithub.com,ndtv.com,denofgeek.com,amazon.com,slickdeals.com,gearpatrol.com,semrush.com,thepointsguy.com'

puts "news.rb"

# Date to process?
if ARGV[0]
  as_of_date = ARGV[0]
else
  raise "Please provide a date to process. Example: ruby news.rb 1975-05-31"
end

# Necessary API credentials?
raise "Please define your News API key: export NEWSAPI_KEY=\"1234\"" if !ENV['NEWSAPI_KEY']

# Determine if we've already processed this date
news_filename = '_posts/'+as_of_date+'-Noise.md'

# Existing Post?
if File.exist? news_filename
  parsed = FrontMatterParser::Parser.parse_file(news_filename)
  if parsed.front_matter['posts']
    posts = parsed.front_matter['posts']
  else
    posts = []
  end
  if parsed.content
    content = parsed.content
  else
    content = ''
  end
else
  posts = []
  content = ''
end

# Get some news
posts = get_crossfit(as_of_date,posts)
posts = get_fitness(as_of_date,posts)

# Build Jekyll Front Matter
front_matter = {
  'layout' => 'post',
  'posts' => posts
}

# Build Jekyll page
puts news_filename
File.open(news_filename, 'w+') do |file|
  file.puts front_matter.to_yaml
  file.puts "---"
  file.puts content
end
