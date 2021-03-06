module ArticlesHelper

  def social_links_for article
    content_tag :ul, class: "social-links" do
      social_link_for(article, :twitter)  +
      social_link_for(article, :facebook) +
      social_link_for(article, :tumblr)
    end
  end

  def social_link_for article, site
    url = case site
    when :twitter
      "https://twitter.com/intent/tweet?text=#{url_encode article.title}&amp;url=#{article_url}&amp;via=crimethinc"
    when :facebook
      "https://www.facebook.com/dialog/feed?app_id=966242223397117&display=popup&caption=#{url_encode article.title}&link=#{article_url}&redirect_uri=#{article_url}"
    when :tumblr
      "http://tumblr.com/widgets/share/tool?canonicalUrl=#{article_url}&amp;caption=#{url_encode article.title}&amp;content=#{article.image}"
    end

    content_tag :li, class: "social-link" do
      link_to "Share on #{site.capitalize}", url, class: "link-domain-#{site}", target: "_blank"
    end
  end

  def figure_image_with_caption_tag(article)
    if article.image.present?
      img = image_tag article.image, class: "u-photo", alt: ""

      if article.image_description.present?
        figcaption = content_tag(:figcaption, article.image_description)
      end

      content_tag :figure, img + figcaption.to_s
    end
  end

  def article_tag(article, &block)
    klasses = ["h-entry"]
    klasses << "article-with-no-header-image" if article.image.blank?

    # Data attributes are used to determine how the article should be polled for updates
    data = { id: article.id, published_at: Time.now.to_i }
    data[:listen] = true if article.collection_posts.recent.any?

    content_tag "article", id: article.slug, class: klasses.join(" "), data: data, &block
  end

  def display_date(datetime=nil)
    unless datetime.nil?
      datetime.strftime("%Y-%m-%d")
    end
  end

  def display_time(datetime=nil)
    unless datetime.nil?
      datetime.strftime("%l:%M&nbsp;%z").html_safe
    end
  end

  def link_to_dates(year: nil, month: nil, day: nil, show_year: true, show_month: true, show_day: true)
    show_month = false if month.nil?
    show_day   = false if day.nil?

    links = []

    month = month.to_s.rjust(2, "0") unless month.nil?
    day   = day.to_s.rjust(2, "0")   unless day.nil?

    if year && show_year
      links << link_to_unless_current(year,  archives_path(year),               rel: "archives", class: "year")
    end
    if month && show_month
      links << link_to_unless_current(month, archives_path(year, month),        rel: "archives", class: "month")
    end
    if day && show_day
      links << link_to_unless_current(day,   archives_path(year, month, day),   rel: "archives", class: "day")
    end

    links.join("-").html_safe
  end

  def publication_status_badge_class article
    article.status.name.downcase == "draft" ? "danger" : "success"
  end

  XML_ENCODING = ::Encoding.find("utf-8")
  require 'builder/xchar'
  def xml_escape(text)
    unless text.nil?
      result = Builder::XChar.encode(text)
      begin
        result.encode(XML_ENCODING)
      rescue
        # if the encoding can't be supported, use numeric character references
        result.
          gsub(/[^\u0000-\u007F]/) {|c| "&##{c.ord};"}.
          force_encoding('ascii')
      end
    end
  end
end
