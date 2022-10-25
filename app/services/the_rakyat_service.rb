class TheRakyatService
  require 'mechanize'

  def initialize()
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths
    cert_store.add_file File.expand_path(Rails.root.join('pem','therakyatpost.pem'))

    @mechanize = Mechanize.new
    @mechanize.user_agent = 'Mac Safari'
    @mechanize.agent.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @mechanize.keep_alive   = true
    @base_url = "https://www.therakyatpost.com"
  end

  def get_categories
    @page = @mechanize.get("#{@base_url}")
    categories = @page.search(".thb-full-menu")[0].search("a")
                  .map{|x| [x.text.to_s.strip, x.attributes["href"].value] }
                  .reject! { |x| x[1].exclude?("/category/") || x[0] == "TrpBM"  }.to_h

    # excluding TrpBM due to already have it in the sub category
  end

  def get_category_posts(category: nil, url: nil)
    @page = @mechanize.get(url)
    posts_url = @page.search(".post-title")
                  .map{|x| { "url": x.search("a")[0].attributes["href"].value} }
                  .compact.uniq
    posts_url
  end

  def get_page_content(url: nil)
    result = Hash.new
    return if url.nil?
    @page = @mechanize.get(url)

    result["author"] = @page.search(".post-author")[0].search("a")[0].text.strip
    result["published_at"] = @page.search(".thb-post-date").text.to_date.beginning_of_day rescue nil
    result["cover_image_url"] = @page.search(".thb-article-featured-image")[0].search("img")[0].attributes["src"].value rescue nil
    result["title"] = @page.search(".entry-title")[0].text.strip

    content = Array.new
    @page.search(".thb-post-share-container")[0]&.search("p")&.each do |x|
      content << ["<p>#{x&.text&.strip}</p>"]
    end
    result["content"] = content.join("")
    result
  end
end