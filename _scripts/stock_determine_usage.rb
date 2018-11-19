#stock_determine_usage.rb

require 'google/cloud/vision'
require 'yaml'

# Get existing list of stock photos
stock_photos = YAML.load_file('./_data/stock.yml')

# Google Vision API
vision = Google::Cloud::Vision.new project: 'joewod-193817'

# Process Photos
stock_photos.each_with_index do |photo,idx|
  puts photo['slug']

  # Skip Photos with Pages
  next if stock_photos[idx].key? 'pages'

  # Build Hosts and Labels
  stock_photos[idx]['pages'] = []
  stock_photos[idx]['labels'] = []

  # Google Vision Image Object
  image = vision.image 'http://www.whiskeytangofoxtrotjoe.com/images/stock/' + photo['slug'] + '.jpg'

  # Call Google Vision Web Resource
  web = image.web

  # Pages With Matching Images
  web.pages_with_matching_images.each do |image|
    stock_photos[idx]['pages'].push(image.url)
  end

  # Google Vision Labels
  labels = image.labels
  labels.each do |label|
    stock_photos[idx]['labels'].push(label.description)
  end

end

# Update the stock photo data
File.open('_data/stock.yml', 'w+') do |file|
  file.puts stock_photos.to_yaml
end
