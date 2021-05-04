module ApplicationHelper
  def is_favorite_checked
    "checked" if params[:is_favorite]
  end

  def fetch_market_list
    Market.all.map { |m| [m.name, m.id] }
  end

  def text_url_to_link(text)
    URI.extract(text, %w[http https]).uniq.each do |url|
      text.gsub!(url, external_link_to(url.to_s, url.to_s))
    end
    text
  end

  def external_link_to(text, href, **option)
    option.merge!({target: :_blank, rel: 'noopener noreferrer'})
    link_to(text, href, option)
  end
end
