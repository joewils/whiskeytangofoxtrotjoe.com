require 'yaml'

puts "Build Stock Photo List"
path = 'images/stock'
photos = []
Dir.foreach(path) do |filename|
  next if filename == '.' 
  next if filename == '..'
  next if filename == '.DS_Store'
  slug = filename.gsub('.jpg','')
  source = 'https://burst.shopify.com/photos/'+filename
  photos.push({'source'=>source,'slug'=>slug})
end
filename = '_data/stock.yml'
if !File.exist? filename
  File.open(filename, 'w+') do |file|
    file.puts photos.shuffle.to_yaml
  end
end