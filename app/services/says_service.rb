class SaysService
  require 'mechanize'

  def initialize()
    @mechanize = Mechanize.new
    @mechanize.user_agent = 'Mac Safari'
    @mechanize.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @mechanize.keep_alive   = true
    @base_url = "https://says.com"
  end

  def get_categories
    @page = @mechanize.get("#{@base_url}/my")
    categories = @page.search(".ga-channel")
                  .map{|x| [x.text.to_s.strip, x.attributes["href"].value] }
                  .reject! { |x| x[1].include?("http") }.to_h
  end

  def get_category_posts(category: nil, url: nil)
    @page = @mechanize.get("#{@base_url}/#{url}")
    if category.name == "Tech"
      output = @mechanize.get("https://says.com/my/api/stories/tech_stories")
      posts_url = JSON.parse(output.body).map{|x| {"url":x["url"], "published_at": x["published_at"]} }
    else
      posts_url = @page.search(".ga-channel-story")
                    .map{|x| { "url": [@base_url,x.attributes["href"].value].join(""), "published_at": nil} }
                    .compact.uniq
    end
    posts_url
  end

  def get_page_content(url: nil, published_at: nil)
    result = Hash.new
    return if url.nil?
    @page = @mechanize.get(url)

    meta_data = @page.search(".story-meta").text.gsub("\n","").gsub("By", "").split("—").map{|x| x.strip }
    # ["Aqasha Nur’aiman", "21 Oct 2022, 05:43 PM", "Updated 3 days ago"]

    result["author"] = meta_data[0]
    if published_at.present?
      result["published_at"] = DateTime.parse(published_at)
    else
      result["published_at"] = DateTime.parse(meta_data[1]) unless meta_data[1].blank?
    end
    result["cover_image_url"] = @page.search(".story-cover-image").map{ |n| n['style'][/url\((.+)\)/, 1] }.first&.gsub('\'','')
    result["title"] = @page.search(".story-title").text
    content = Array.new
    @page.search(".story-content-left").search(".text, .image").each do |x|
      # check image
      if x.search(".single-image-wrap").present?
        x.search(".single-image-wrap").map do |img_wrap|
          image_url = img_wrap.children.map{|x| x["href"] }.compact.first
          unless image_url.blank?
            content << ["<img src='#{image_url}' />"]
          end
        end
      else
        content << ["<p>#{x.text.strip}</p>"]
      end
    end
    result["content"] = content.join("")
    result
  end
end