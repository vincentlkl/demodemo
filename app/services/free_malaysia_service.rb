class FreeMalaysiaService
  require 'mechanize'

  def initialize()
    @mechanize = Mechanize.new
    @mechanize.user_agent = 'Mac Safari'
    @mechanize.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @mechanize.keep_alive   = true
    @base_url = "https://www.freemalaysiatoday.com"
  end

  def get_categories
    @page = @mechanize.get("#{@base_url}")

    categories = @page.search(".menu-header-menu-container").first.search("li")
                  .map{|x| [x.children.first.text.to_s, x.children.first.attributes["href"]&.value] }
                  .reject! {|x| x[1].include?("http") }.to_h
  end

  def get_category_posts(category: nil, url: nil)
    @page = @mechanize.get("#{@base_url}#{url}")
    posts_url = @page.search(".td-module-thumb")
                .map{|x| { "url": x.children.map{|x| x.attributes["href"].value}.first} }
                .compact.uniq
    posts_url
  end

  def get_page_content(url: nil)
    result = Hash.new
    return if url.nil?
    @page = @mechanize.get(url)

    author = @page.search(".td-post-author-name").text.gsub(" - ", "").gsub("By ", "").strip
    result["author"] = author

    published_time = @page.search(".td-post-date")[0].children.first.attributes["datetime"].value
    result["published_at"] = DateTime.parse(published_time) unless published_time.blank?

    result["cover_image_url"] = @page.search(".td-post-content").search("img").first.attributes["src"].value
    result["title"] = @page.search(".entry-title")[0].text
    content = Array.new
    img_count = 0
    @page.search(".td-post-content").search("p, img").each do |x|
      # check image
      if x.name == "img"
        img_count += 1
        # next if img_count == 1
        image_url = x.attributes["src"].value
        unless image_url.blank?
          content << ["<img src='#{image_url}' />"]
        end
      else
        content << ["<p>#{x.text.strip}</p>"]
      end
    end
    result["content"] = content.join("")
    result
  end
end