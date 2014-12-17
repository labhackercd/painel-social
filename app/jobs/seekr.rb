class Seekr < Faraday::Middleware
  extend Forwardable

  def_delegators :'Faraday::Utils', :parse_query, :build_query

  def call(env)
    ts = timestamp
    query = query_params(env.url)
    query = query.merge({:ts => ts, :key => @key.to_s, :hash => hash(ts)})
    env.url.query = query.to_query
    @app.call(env)
  end

  def timestamp
    Time.zone.now.to_time.to_i
  end

  def hash(ts)
    Digest::SHA1.hexdigest("#{@secret}#{ts}")
  end

  def query_params(url)
    if url.query.nil? or url.query.empty?
      {}
    else
      parse_query url.query
    end
  end

  def initialize(app, key, secret)
    super(app)
    @key = key
    @secret = secret
  end
end

module Faraday
  class Request
    register_middleware :seekr => lambda { Seekr }
  end
end

class TwitterProcess
  @queue = 'twitter'

  def self.perform(slug, searchid)
    seekr = self.client

    tweets = Array.new

    (0..10).to_a.each do |page|
      page = seekr.get 'search_results.json', {
        :search_id => searchid,
        :per_page => 100,
        :page => page
      }
      page = JSON.parse page.body
      page = page['search_results']

      tweets += page.find_all { |i| i['social_media'].match(/twitter/) }

      break if page.length == 0
    end

    mentions = tweets.map do |t|
      {
        :text => t['text'].gsub(URI.regexp, '<a href="\0">\0</a>'),
        :author => t['user'],
        :author_image => t['user_image'],
        :published_at => t['published_on']
      }
    end

    Dashing.send_event("#{slug}_twitter_mentions", {:comments => mentions}, :cache => true)

    freqmap = Hash.new(0)

    tweets.each do |t|
      words = UnicodeUtils.downcase(t['text'])
      words = words.split(/[\s,.;'\?\!\+]/)
      words.each do |w|
        freqmap[w] += 1 if w.start_with?('#')
      end
    end

    if freqmap.length > 0
      factor = 40.0 / freqmap.values.sort.last.to_f
    else
      factor = 1
    end

    wordcloud = freqmap.map do |word, count|
      { :text => word,
        :size => count * factor,
        :link => "https://twitter.com/search?q=" + URI::encode(word) + "&lang=pt"
      }
    end

    info = "Baseado em #{freqmap.values.inject(:+)} hashtags presentes em #{mentions.length} tweets"
    Dashing.send_event("#{slug}_twitter_wordcloud", {:value => wordcloud, :moreinfo => info}, :cache => true)
  end

  def self.client
    Faraday.new('http://monitoramento.seekr.com.br/api/') do |f|
      secrets = Rails.application.secrets.seekr

      f.request :seekr, secrets['api_key'], secrets['api_secret']
      f.adapter  Faraday.default_adapter
    end
  end
end
