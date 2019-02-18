#stock_build_pages.rb

require 'yaml'

# Stock Photos
photos = YAML.load_file('./_data/stock.yml')

# Ignore List
ignore = [
  '1sucai.com',
  'taopic.com',
  'freerangestock.com',
  '7xsoft.com',
  'xixidown.com',
  'yyxx5.com',
  'publicdomainq.net',
  '.xml',
  'shopify.com',
  'aliexpress.com',
  'chinese-phone.com',
  'facebook',
  '%E0%B8',
  '%D8%B5',
  '%E5%81',
  '%E3%83',
  'myshopify.com',
  'pixels-library.com',
  '.com.br',
  'pixnet.net',
  'fanxianke.com',
  'flipboard.com',
  'justfreethemes.com',
  '_hstc',
  'lovepik.com',
  '.com.'
]

photos.each_with_index do |photo,idx|
  puts photo['slug']

  # Build Jekyll Front Matter
  front_matter = {
    'layout' => 'stock',
    'slug' => photo['slug'],
    'source' => photo['source'],
    'labels' => photo['labels'],
    'pages' => []
  }
  # Scrub the Related Pages
  photo['pages'].each do |page|
    bad = ignore.any? {|word| page.include? word}
    bad = true unless page.include? '.com' or page.include? '.net' or page.include? '.org'
    bad = true if page.count('-') > 24
    front_matter['pages'].push(page) if bad == false
  end
  # Build a Jekyll page, but only if one doesn't exist.
  # We don't want to override any hand crafted content.
  filename = 'candy/'+photo['slug']+'.md'
  if !File.exist? filename
    File.open(filename, 'w+') do |file|
      file.puts front_matter.to_yaml
      file.puts "---"
    end
  end
end