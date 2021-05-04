class Brand < ApplicationRecord
  belongs_to :company
  belongs_to :market
  has_many :accounts
  has_many :brand_lifts
  has_many :posts
  has_many :talk_posts
  has_many :landing_pages
  has_many :brand_lift_values

  def brandlift_per_date(brandlift_month, type_id)
    first_day, last_day = brandlift_month_to_span(brandlift_month)
    brandlift_data = brand_lift_values.where(type_id: type_id)
                                      .between_date(first_day, last_day)
                                      .order(date: :asc)
                                      .map{ |bl| {date: bl.date, value: bl.value} }
    return [] if brandlift_data.empty?

    first_day.upto(last_day) do |date|
      unless brandlift_data.any?{|d| d[:date] == date }
        value = brandlift_data.reverse.find{|d| d[:date] < date }&.fetch(:value) || 0
        brandlift_data.unshift({ date: date, value: value, none: true })
      end
    end
    brandlift_data.sort{|a, b| a[:date] <=> b[:date]}
                  .map {|d| {date: d[:date].to_s, value: d[:value], none: d[:none]}}
  end

  def posts_per_date(brandlift_month)
    first_day, last_day = brandlift_month_to_span(brandlift_month)
    posts_per_date = posts
      .between_posted_on(first_day, last_day)
      .group(:media, :posted_on)
      .select("media, posted_on, count(*) as post_count")

    posts_per_date.map do |r|
      {
        media:     r.media,
        posted_on: r.posted_on,
        sum:       r.post_count,
      }
    end.to_json
  end

  def talk_posts_per_date(brandlift_month)
    first_day, last_day = brandlift_month_to_span(brandlift_month)
    talk_posts_per_date = talk_posts
      .between_posted_on(first_day, last_day)
      .group(:posted_on)
      .select("'LINE' as media, posted_on, count(*) as post_count")

    talk_posts_per_date.map do |r|
      {
        media:     r.media,
        posted_on: r.posted_on,
        sum:       r.post_count,
      }
    end.to_json
  end

  def self.month_lists
    (1..12).map do |month|
      { str: "2021年#{month}月", value: "2021-#{month}" }
    end
  end

  private

  def brandlift_month_to_span(brandlift_month)
    brandlift_month = "#{Date.today.year}-#{Date.today.month}" if brandlift_month.blank?
    year, month = brandlift_month.split("-").map(&:to_i)
    first_day = Date.new(year,month, 1)
    last_day = [Date.today, first_day.end_of_month].min
    [first_day, last_day]
  end
end
