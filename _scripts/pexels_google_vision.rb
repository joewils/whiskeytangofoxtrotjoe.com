#pexels_google_vision.rb

require 'google/cloud/vision'
require 'yaml'

# Get existing list of stock photos
stock_photos = YAML.load_file('./_data/pexels.yml')

# Get matching pages data file
matching_pages = YAML.load_file('./_data/pexels_matching.yml')

# Google Vision API
vision = Google::Cloud::Vision.new project: 'joewod-193817'

# Process Photos
stock_photos.first(10).each_with_index do |photo,idx|
  puts photo['slug']

  # Skip Photos with Pages
  next if matching_pages[photo['pexel_id']]

  # Build Hosts and Labels
  matching_pages[photo['pexel_id']]['hosts'] = []
  matching_pages[photo['pexel_id']]['labels'] = []

  # Google Vision Image Object
  image = vision.image 'http://www.whiskeytangofoxtrotjoe.com/' + photo['local_href']

  # Call Google Vision Web Resource
  web = image.web

  # Pages With Matching Images
  web.pages_with_matching_images.each do |image|
    matching_pages[photo['pexel_id']]['hosts'].push(image.url)
  end

  # Google Vision Labels
  labels = image.labels
  labels.each do |label|
    matching_pages[photo['pexel_id']]['labels'].push(label.description)
  end
end

# Update the stock photo data
File.open('./_data/pexels_matching.yml', 'w+') do |file|
  file.puts matching_pages.to_yaml
end