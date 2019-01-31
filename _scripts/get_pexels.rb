# https://www.pexels.com/search/fitness/
# https://www.pexels.com/search/fitness/?page=1&format=js

require 'digest/sha1'
require 'httparty'
require 'htmlentities'
require 'json'
require 'nokogiri'
require 'uri'
require 'yaml'

def get_pexels(page=1,image_data=[])
  puts "https://www.pexels.com/search/fitness/" + page.to_s
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
  # Get HTML
  todays_date = Date.today.to_s
  filename = '_html/pexels-'+page.to_s+'.html'
  if !File.exist? filename
    sleep(rand(3..6)) # play nice
    # Craft URL
    url = 'https://www.pexels.com/search/fitness/?page='+page.to_s+'&format=js'
    html = HTTParty.get(url, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
    if html.response.code.to_s == '200'
      File.open(filename, 'w+') do |file|
        file.puts html
      end
    end
  end
  # Process HTML
  if File.exist? filename
    pexel_string = File.read(filename)
    #fix escaped strings
    pexel_string.gsub!("\\'","'")
    pexel_string.gsub!('\"','"')
    # iterate over images using regex
    regex = /<img\s(.*?)\s\/>/
    pexel_string.scan(regex).each do |match|
        # we only need 365 images
        next if image_data.length > 365
        # rebuild image string for nokogiri
        img = '<img ' + match[0] + ' />'
        doc = Nokogiri::HTML(img)
        srcset = doc.css('img').attr('srcset')
        width = doc.css('img').attr('data-image-width')
        height = doc.css('img').attr('data-image-height')
        # only process images with srsset data and a horizontal landscape orientation
        if srcset and width and height and (width.value.to_f > height.value.to_f)
            if false
                doc.css('img').each do |node|
                    node.each do |attr_name,attr_val|
                        puts "\t" + attr_name + ": " + attr_val
                    end
                end
                puts "----------"
            end
            alt = doc.css('img').attr('alt').value
            href = doc.css('img').attr('data-big-src').value
            # determine pexel id from href
            bits = href.split('/')
            pexel_id = bits[4]
            # build slug from alt string
            slug = alt.downcase.gsub(' ','-').gsub(',','').gsub("'",'').gsub('.','') + '-' + pexel_id
            # build source from slug
            source = 'https://www.pexels.com/photo/'+slug+'/'
            # get the image
            image_got = false
            image_filename = 'images/stock/'+slug+'.jpg'
            if File.exist? image_filename
                image_got = true
            else
                sleep(rand(3..6)) # play nice
                image = HTTParty.get(href, {:format=>'plain', headers: {"User-Agent" => agents.sample}})
                if image.response.code.to_s == '200'
                    File.open(image_filename, 'w+') do |file|
                        file.puts image
                    end
                    image_got = true
                end #image.response
            end #image_filename
            # update image_data
            image_data.push({
                'alt' => alt,
                'href' => href,
                'pexel_id' => pexel_id,
                'source' => source,
                'slug' => slug,
                'local_href' => image_filename,
                'image_got' => image_got
            })
        end
    end
  end

  return image_data
end

data = []
(1..16).each do |idx|
    data = get_pexels(idx,data)
end

puts data.length

filename = '_data/pexels.yml'
File.open(filename, 'w+') do |file|
    file.puts data.shuffle.to_yaml
end