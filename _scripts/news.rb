require 'digest/sha1'
require 'httparty'
require 'htmlentities'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

require_relative './_user_agents'
require_relative './_get_news'
require_relative './_get_crossfit_journal'
require_relative './_get_crossfit_mainsite'
require_relative './_get_grams'
require_relative './_get_tierthreetactical'
require_relative './_get_tnation'
require_relative './_get_shape'

puts "news.rb"

if ARGV[0]
  as_of_date = ARGV[0]
else
  raise "Please provide a date to process. Example: ruby news.rb 2018-05-31"
end

# Posts
posts = []

# Sources
sources = YAML.load_file('./_data/sources.yml')

# Process sources with an RSS feed
sources.each do |source|
  if source['feed'] and source['feed'] != ''
    news = get_news(source['feed'],source['title'],as_of_date,source['category'])
    posts.push(*news)
  end
end

# Process CrossFit Journal JSON feed
news = get_crossfit_journal(as_of_date)
posts.push(*news)

# Process CrossFit Mainsite JSON feed
news = get_crossfit_mainsite(as_of_date)
posts.push(*news)

# Process Tier Three Tactical HTML page
news = get_tierthreetactical(as_of_date)
posts.push(*news)

# Process T-Nation HTML page
news = get_tnation(as_of_date)
posts.push(*news)

# Process Shape HTML page
news = get_shape(as_of_date)
posts.push(*news)

# IG Sources
grams = YAML.load_file('./_data/grams.yml')

# Process IG
grams.each do |source|
  news = get_grams(source['ig'],as_of_date)
  posts.push(*news)
end

# Men's Fitness?
# https://www.menshealth.com/fitness/

# https://blog.feedspot.com/fitness_rss_feeds/
# 

# Build Jekyll Front Matter
front_matter = {
  'layout' => 'post',
  'links' => posts.shuffle
}

# Build a Jekyll page, but only if one doesn't exist.
# We don't want to override any hand crafted content.
news_filename = '_posts/'+as_of_date+'-Noise.md'
if !File.exist? news_filename
  File.open(news_filename, 'w+') do |file|
    file.puts front_matter.to_yaml
    file.puts "---"
  end
end