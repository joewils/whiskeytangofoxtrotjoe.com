require 'base64'
require 'front_matter_parser'
require 'json'
require 'news-api'
require 'yaml'

require_relative('_get_crossfit')
require_relative('_get_fitness')

puts "news.rb"

# Date to process?
if ARGV[0]
  as_of_date = ARGV[0]
else
  raise "Please provide a date to process. Example: ruby news.rb 2018-05-31"
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

posts = get_crossfit(as_of_date,posts)
posts = get_fitness(as_of_date,posts)


# Build Jekyll Front Matter
front_matter = {
  'layout' => 'post',
  'posts' => posts.first(13)
}

# Build Jekyll page
File.open(news_filename, 'w+') do |file|
  file.puts front_matter.to_yaml
  file.puts "---"
  file.puts content
end
