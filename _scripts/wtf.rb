#!/usr/bin/env ruby

require 'base64'
require 'date'
require 'front_matter_parser'
require 'json'
require 'news-api'
require 'yaml'

puts "wtf.rb"

# Necessary API credentials?
raise "Please define your News API key: export NEWSAPI_KEY=\"1234\"" if !ENV['NEWSAPI_KEY']

# Date to process?
as_of_dates = []
if ARGV[0]
    as_of_dates.push(ARGV[0])
else
    # Determine the latest news date by looking for the most recent -News.md file (/posts/2019-05-31-News.md)
    latest_date = nil
    posts = Dir.entries('_posts')
    posts.sort.reverse.each do |post|
      if post.include? '-News.md'
        date_string = post.gsub('-News.md','')
        latest_date = Date.parse(date_string) 
        break
      end
    end
    # Determine todays date
    todays_date = Date.today
    # Build list of dates to process
    (latest_date..todays_date).each do |date|
      as_of_dates.push(date.strftime("%Y-%m-%d"))
    end
end
  
# News Sources
sources = [
    'abc-news',
    #'al-jazeera-english',
    #'associated-press',
    #'ars-technica',
    #'axios',
    'bbc-news',
    #'bloomberg',
    #'cbc-news',
    'cbs-news',
    'cnbc',
    'cnn',
    #'espn',
    'fox-news',
    #'fox-sports',
    'msnbc',
    #'national-geographic',
    'nbc-news',
    #'polygon',
    #'reuters',
    #'the-economist',
    'the-new-york-times',
    #'the-verge',
    'the-washington-post',
    'the-wall-street-journal',
    #'time',
    #'usa-today',
    #'vice-news',
    #'wired'
]

# Process news for the following dates
as_of_dates.each do |as_of_date|
  # Save all the news for "Index" page build
  all_the_news = {}

  # Process all the news sources
  sources.each do |source|
      puts "\t" + source
      
      # Determine if we've already processed this date
      news_filename = '_posts/' + as_of_date + '-' + source + '.md'

      # Existing Post?
      if File.exist? news_filename
          parsed = FrontMatterParser::Parser.parse_file(news_filename)
          if parsed.front_matter['articles']
              articles = parsed.front_matter['articles']
          else
              articles = []
          end
          if parsed.content
              content = parsed.content
          else
              content = ''
          end
      else
          articles = []
          content = ''
      end

      # Skip if we already have news articles
      if articles.length == 0

          # News API
          newsapi = News.new(ENV['NEWSAPI_KEY'])

          # News Articles
          news = newsapi.get_everything(
              from: as_of_date,
              to: as_of_date,
              language: 'en',
              page: 1,
              pageSize: 7,
              sources: source
          )

          # Reformat Article Data
          news.each do |article|
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
              articles.each do |p|
                  existing_post = true if p['url'] and p['url'] == post['url']
              end
              articles.push(post) if existing_post == false
          end
          
          # Build Jekyll Front Matter
          front_matter = {
              'layout' => 'bootstrap-post',
              'articles' => articles,
              'as_of_date' => as_of_date
          }
      
          # Build Jekyll page
          puts news_filename
          File.open(news_filename, 'w+') do |file|
              file.puts front_matter.to_yaml
              file.puts "---"
              file.puts content
          end

      end # articles.length == 0

      # Save news for "Index" page build
      all_the_news[source] = articles

  end # sources.each

  # Shuffle the order of the publishers
  shuffled_news = {}
  all_the_news.keys.shuffle.each do |key|
      shuffled_news[key] = all_the_news[key]
  end

  # Build featured news hash
  featured_publishers = all_the_news.keys.shuffle.first(4)
  featured_news = []
  featured_publishers.each do |source|
      featured_news.push(all_the_news[source][0])
  end

  # Build "Index" page of todays news organized by publisher
  todays_index_filename = '_posts/' + as_of_date + '-News.md'

  # Build Jekyll Front Matter
  front_matter = {
      'title' => 'News and Noise ' + as_of_date,
      'as_of_date' => as_of_date,
      'layout' => 'bootstrap-news',
      'categories' => 'summary',
      'featured_news' => featured_news,
      'news' => shuffled_news
  }

  # Build Jekyll page
  puts todays_index_filename
  File.open(todays_index_filename, 'w+') do |file|
      file.puts front_matter.to_yaml
      file.puts "---"
  end

end #as_of_dates.each

# Execute Shell Commands to Update GitHub
status = `git status`
add = `git add .`
commit = `git commit -m "wtf noise"`
puts status
puts add
puts commit