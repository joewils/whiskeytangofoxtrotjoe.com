require 'base64'
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

if !File.exist? news_filename

  # Posts
  posts = []

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
    posts.push(post)
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
  end

else
  puts "Nothing todo. We've already processed: " + as_of_date + "."
end