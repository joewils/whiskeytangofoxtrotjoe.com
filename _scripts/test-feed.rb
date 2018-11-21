require 'digest/sha1'
require 'httparty'
require 'htmlentities'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

require_relative './_get_news'

title = 'Pop Sugar'
source = 'https://www.popsugar.com/fitness/'
feed = 'https://www.popsugar.com/fitness/feed'
as_of_date = '2018-11-20'
category = nil

news = get_news(feed,title,as_of_date,category)

puts news