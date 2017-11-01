require 'bundler/setup'
require 'dotenv'
require 'twitter'
require 'mastodon'

module SyncMstdnTwi
  class << self
    def run(envfile)
      Dotenv.load(envfile) if envfile

      lack_env = check_env(ENV.keys)
      unless lack_env.empty?
        STDERR.puts 'Not enough environment variable'
        lack_env.each do |env|
          STDERR.puts "  #{env}"
        end
        exit 1
      end

      Twitter::Streaming::Client.new(twitter_config).filter(follow: ENV['TWITTER_USER_IDS']) do |status|
        next unless status.is_a? Twitter::Tweet
        next if status.retweet? || !ENV['TWITTER_USER_IDS'].include?(status.user.id.to_s)

        application_name = CGI.unescapeHTML(status.source.gsub(%r{</?[^>]*>}, ''))
        if applications.include?(application_name)
          message = ''
          index = 0

          status.urls.each do |url|
            message += status.text[index...url.indices.first] + url.attrs[:expanded_url]
            index = url.indices.last
          end
          message += status.text[index..-1]

          post_to_mastodon(CGI.unescapeHTML(message))
        end
      end
    end

    private

    def check_env(env_list)
      target_env = %w(
        TWITTER_CONSUMER_KEY
        TWITTER_CONSUMER_SECRET
        TWITTER_OAUTH_TOKEN
        TWITTER_OAUTH_TOKEN_SECRET
        TWITTER_USER_IDS
        MASTODON_URL
        MASTODON_ACCESS_TOKEN
      )
      target_env - env_list
    end

    def twitter_config
      @twitter_config ||= {
        consumer_key: ENV['TWITTER_CONSUMER_KEY'],
        consumer_secret: ENV['TWITTER_CONSUMER_SECRET'],
        access_token: ENV['TWITTER_OAUTH_TOKEN'],
        access_token_secret: ENV['TWITTER_OAUTH_TOKEN_SECRET']
      }
    end

    def mastodon_client
      @mastodon_client ||= Mastodon::REST::Client.new(
        base_url: ENV['MASTODON_URL'],
        bearer_token: ENV['MASTODON_ACCESS_TOKEN']
      )
    end

    def post_to_mastodon(message)
      mastodon_client.create_status(message)
    end

    def applications
      @applications ||= begin
        1.upto(10).map { |i|
          ENV["APPLICATION_#{i}"]
        }.compact
      end
    end
  end
end
