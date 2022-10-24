# bundle exec rake generate_free_malaysia_posts:generate
namespace :generate_free_malaysia_posts do
  task generate: :environment do
    puts "starts at #{Time.zone.now}"
    service_categories = FreeMalaysiaService.new.get_categories

    # getting from each categories
    service_categories.each do |category_name, url|
      category = Category.where(name: category_name).first_or_create
      category_post_urls = FreeMalaysiaService.new.get_category_posts(category: category, url: url)

      category_post_urls&.each do |post_url|
        content = FreeMalaysiaService.new.get_page_content(url: post_url[:url])
        post = Post.where(url: post_url[:url], provider: :free_malaysia).first_or_initialize
        post.category_id = category.id
        post.author = content['author']
        post.title = content['title']
        post.content = content['content']
        post.cover_image_url = content['cover_image_url']
        post.published_at = content['published_at']
        post.save
      end
    end

    puts "completed at #{Time.zone.now}"
  end
end
