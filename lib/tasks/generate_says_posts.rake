# bundle exec rake generate_says_posts:generate
namespace :generate_says_posts do
  task generate: :environment do
    puts "starts at #{Time.zone.now}"
    service_categories = SaysService.new.get_categories

    # getting from each categories
    service_categories.each do |category_name, url|
      category = Category.where(name: category_name).first_or_create
      category_post_urls = SaysService.new.get_category_posts(category: category, url: url)

      category_post_urls&.each do |post_url|
        break if index > 8
        content = SaysService.new.get_page_content(url: post_url[:url], published_at: post_url[:published_at])

        post = Post.where(url: post_url[:url], provider: :says).first_or_initialize
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
