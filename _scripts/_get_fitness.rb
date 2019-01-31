
def get_fitness(as_of_date,posts)
  # News API
  newsapi = News.new(ENV['NEWSAPI_KEY'])
  # Fitness Articles
  articles = newsapi.get_everything(
    q: 'fitness AND exercise',
    from: as_of_date,
    to: as_of_date,
    language: 'en',
    sortBy: 'relevancy',
    page: 1,
    pageSize: 13,
    excludeDomains: 'hvper.com,businesswire.com,thehollywoodgossip.com,lithub.com,ndtv.com,denofgeek.com,amazon.com,slickdeals.com,gearpatrol.com,semrush.com'
  )
  # Reformat Article Data
  articles.each do |article|
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
    posts.each do |p|
      if p['url'] and p['url'] == post['url']
        existing_post = true
      end
    end
    if existing_post == false and post['title'] and post['title'] != ''
      posts.push(post) 
    end
  end
  return posts
end