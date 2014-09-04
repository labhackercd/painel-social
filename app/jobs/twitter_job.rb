require 'time'
require 'twitter'
require 'open-uri'
require 'unicode_utils/downcase'


class TwitterProcess
  @queue = 'twitter'

  def self.perform(slug, query)
    #### Get your twitter keys & secrets:
    #### https://dev.twitter.com/docs/auth/tokens-devtwittercom
    twitter = Twitter::REST::Client.new do |config|
      secrets = Rails.application.secrets.twitter

      config.consumer_key = secrets['consumer_key']
      config.consumer_secret = secrets['consumer_secret']
      config.access_token = secrets['access_token']
      config.access_token_secret = secrets['access_token_secret']
    end

    begin
      tweets = []
      
      max_id = Float::INFINITY
      oldest = Time.now

      t = twitter.search(URI::encode(query), :result_type => "recent", :lang => "pt")
      for i in (0..2)
        t.each do | tweet |
          tweets.push(tweet)
          
          if max_id < tweet.id
            max_id = tweet.id
          end
          
          timestamp = tweet.created_at
          if oldest > timestamp
            oldest = timestamp
          end
        end
    
        if i >= 1
          t = twitter.search(URI::encode(query), :result_type => "recent", :max_id => max_id, :lang => "pt")
        end
      end

      frequency = Hash.new(0)
      tweets.each do |tweet|
        words = tweet.text.split(/[\s,.;'\?\!\+]/)
        words.each do |word|
          word = UnicodeUtils.downcase(word)
          
          if word.start_with?("#")
            frequency[word] += 1
          end
        end
      end
      
      if frequency.length > 0
        max_freq = frequency.max_by{|k,v| v}[1]
        max_size = 40
        factor = max_size.to_f / max_freq.to_f
      else
        factor = 1
      end

      wordcloud = Array.new
      frequency.each do |word, count|
        wordcloud.push({ text: word, size: count * factor, link: "https://twitter.com/search?q=" + URI::encode(word) + "&lang=pt"})
      end
      
      time_span = Time.now - oldest
      hours = (time_span / 3600).round
      
      event = {value: wordcloud, moreinfo: 'Hashtags associados à busca "%s"<br />(baseado em %s tweets nas últimas %s horas)' % [query, tweets.count, hours]}
      Dashing.send_event(slug+'_twitter_wordcloud', event, :cache => true)

      tweets = tweets.map do |tweet|
        text = tweet.text
        text = text.gsub(URI.regexp, '<a href="\0">\0</a>')
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https.to_s }
      end
      
      if query.start_with?('@')
        moreinfo = 'Mensagens recentes no twitter direcionadas a %s<br />(baseado em %s tweets nas últimas %s horas)' % [query, tweets.count, hours]
      else
        moreinfo = 'Mensagens recentes no twitter relacionadas à busca "%s"<br />(baseado em %s tweets nas últimas %s horas)' % [query, tweets.count, hours]
      end
      
      event = {comments: tweets, moreinfo: moreinfo}
      Dashing.send_event(slug+'_twitter_mentions', event, :cache => true)
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
