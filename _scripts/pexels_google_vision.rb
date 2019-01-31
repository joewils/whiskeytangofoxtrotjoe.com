#pexels_google_vision.rb

require 'google/cloud/vision'
require 'yaml'

# Get existing list of stock photos
stock_photos = YAML.load_file('_data/pexels.yml')

# Get matching pages data file
matching_pages = YAML.load_file('_data/pexels_matching.yml')

# Google Vision API
image_annotator = Google::Cloud::Vision::ImageAnnotator.new

# Process Photos
stock_photos.each do |photo|
  puts photo['slug']

  # Skip Photos with Pages
  next if matching_pages.has_key? photo['pexel_id']

  # Build Hosts
  matching_pages[photo['pexel_id']] = []

  # Google Vision
  response = image_annotator.web_detection(
    image: 'http://www.whiskeytangofoxtrotjoe.com/' + photo['local_href'],
    max_results: 24
  )
  response.responses.each do |res|
    if res.web_detection.pages_with_matching_images
        res.web_detection.pages_with_matching_images.each do |match|
            matching_pages[photo['pexel_id']].push(match.url)
        end
    end
  end
end

# Update the stock photo data
File.open('./_data/pexels_matching.yml', 'w+') do |file|
  file.puts matching_pages.to_yaml
end