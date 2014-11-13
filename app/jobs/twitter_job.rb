require 'time'
require 'twitter'
require 'open-uri'
require 'unicode_utils/downcase'

class TwitterProcess
  @queue = 'twitter'

  def self.perform(slug, query)
    twitter = Twitter::REST::Client.new do |config|
      secrets = Rails.application.secrets.twitter

      config.consumer_key = secrets['consumer_key']
      config.consumer_secret = secrets['consumer_secret']
      config.access_token = secrets['access_token']
      config.access_token_secret = secrets['access_token_secret']
    end

    begin
      tweets = twitter.search(
        URI::encode(query),
        :result_type => "recent",
        :lang => "pt",
      )

      mentions = tweets.map do |t|
        # XXX `to_json` breaks with hashes containing `Twitter::NullObject`s
        name = t.user.name
        name = nil if name.nil?

        {
          :name => name,
          :body => t.text.gsub(URI.regexp, '<a href="\0">\0</a>'),
          :avatar => t.user.profile_image_url_https.to_s,
          :created_at => t.created_at
        }
      end

      Dashing.send_event("#{slug}_twitter_mentions", {:comments => mentions}, :cache => true)

      freqmap = Hash.new(0)

      tweets.each do |t|
        words = UnicodeUtils.downcase(t.text)
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

      info = "Baseado em #{freqmap.values.inject(:+)} hashtags presentes em #{mentions.length}"
      Dashing.send_event("#{slug}_twitter_wordcloud", {:value => wordcloud, :moreinfo => info}, :cache => true)
    end
  end
end


class UpdatePanels
  def self.perform
    Panel.connection
    Panel.all.each do |p|
      Resque.enqueue(TwitterProcess, p.slug, p.query)
    end
  end
end
