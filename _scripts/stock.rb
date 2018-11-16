# https://burst.shopify.com/fitness
# https://cloud.google.com/vision/
require 'digest/sha1'
require 'httparty'
require 'htmlentities'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

def get_burst(page=1)
  puts "https://burst.shopify.com/fitness"
  # User Agents
  agents = [
    'Mozilla/5.0 (Windows NT 10.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1',
    'Mozilla/5.0 (Windows NT 6.2; rv:22.0) Gecko/20130405 Firefox/23.0',
    'Mozilla/5.0 (Windows NT 6.1; WOW64; Trident/7.0; AS; rv:11.0) like Gecko',
    'Mozilla/5.0 (Windows; U; MSIE 9.0; WIndows NT 9.0; en-US))',
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.75.14 (KHTML, like Gecko) Version/7.0.3 Safari/7046A194A',
    'Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10_6_8; de-at) AppleWebKit/533.21.1 (KHTML, like Gecko) Version/5.0.5 Safari/533.21.1'
  ]
  # Get IG HTML
  todays_date = Date.today.to_s
  filename = '_html/burst-'+page.to_s+'.html'
  if !File.exist? filename
    sleep(rand(1..3)) # play nice
    # Craft Instagram post URL
    url = 'https://burst.shopify.com/fitness?page='+page.to_s
    html = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
    if html.response.code.to_s == '200'
      File.open(filename, 'w+') do |file|
        file.puts html
      end
    end
  end
  # Process HTML
  if File.exist? filename
    doc = File.open(filename) { |f| Nokogiri::XML(f) }
    if doc
      # Do something
      doc.css("a[class='photo-tile__image-wrapper']").each do |anchor|
        puts source_url = 'https://burst.shopify.com' + anchor['href']
        slug = anchor['href'].split('/')[2]
        image_path = 'https://burst.shopifycdn.com/photos/'+slug+'_925x.jpg'
        image_filename = 'images/stock/'+slug+'.jpg'
        if !File.exist? image_filename
          sleep(rand(1..3)) # play nice
          image = HTTParty.get(image_path, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
          if image.response.code.to_s == '200'
            File.open(image_filename, 'w+') do |file|
              file.puts image
            end
          end #image.response
        end # image_filename
      end # doc.css
    end # if doc
  end # File.exist?
  return true
end

foo = get_burst(2)

