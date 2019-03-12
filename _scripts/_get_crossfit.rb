
def get_crossfit(as_of_date,posts)
  # News API
  newsapi = News.new(ENV['NEWSAPI_KEY'])
  # CrossFit News Articles
  articles = newsapi.get_everything(
    q: 'crossfit',
    from: as_of_date,
    to: as_of_date,
    language: 'en',
    sortBy: 'relevancy',
    page: 1,
    pageSize: 20,
    excludeDomains: $exclude_domains
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
    posts.push(post) if existing_post == false
  end
  return posts
end