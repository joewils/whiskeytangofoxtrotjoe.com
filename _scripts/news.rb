require 'base64'
require 'front_matter_parser'
require 'json'
require 'news-api'
require 'yaml'

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

  # News API
  newsapi = News.new(ENV['NEWSAPI_KEY'])

  # News Articles
  articles = newsapi.get_everything(
    q: 'crossfit',
    from: as_of_date,
    to: as_of_date,
    language: 'en',
    sortBy: 'popularity',
    page: 1,
    pageSize: 100
  )

  # Reformat Article Data
  articles.each do |article|
    post = {
      'title' => article.title,
      'url' => article.url,
      'image' => article.urlToImage,
      'source' => article.name,
      'description' => ''
    }
    post['description'] = article.description.gsub(/\r/," ").gsub(/\n/," ") if article.description
    # Determine if we've already seen this news article
    existing_post = false
    posts.each do |p|
      if p['url'] and p['url'] == post['url']
        existing_post = true
      end
    end
    posts.push(post) if existing_post == false
  end

  # Build Jekyll Front Matter
  front_matter = {
    'layout' => 'post',
    'posts' => posts
  }

  # Build Jekyll page
  File.open(news_filename, 'w+') do |file|
    file.puts front_matter.to_yaml
    file.puts "---"
    file.puts content
  end
