# frozen_string_literal: true

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
        warn 'Not enough environment variable'
        lack_env.each do |env|
          warn "  #{env}"
        end
        exit 1
      end

      main
    end

    private

    def main
      loop do
        fetch_statuses.reverse_each do |status|
          next if status.retweet? || !match_application?(status)

          message = build_message(status)
          post_to_mastodon(message)
        end

        # Max 1500 requests / 15-min
        sleep 10
      end
    end

    def fetch_statuses
      is_first_fetch = @since_id.nil?

      params = { count: 200, include_rts: false }
      params[:since_id] = @since_id if @since_id
      statuses = client.user_timeline(user, params).to_a
      @since_id = statuses.first.id unless statuses.empty?

      # Tweets acquired for the first time are not subject to notification
      return [] if is_first_fetch

      statuses
    rescue Twitter::Error::TooManyRequests, HTTP::ConnectionError => e
      warn e.inspect
      []
    end

    def user
      @user ||= client.verify_credentials
    end

    def match_application?(status)
      application_name = CGI.unescapeHTML(status.source.gsub(%r{</?[^>]*>}, ''))
      applications.include?(application_name)
    end

    def build_message(status)
      message = ''
      index = 0

      status.urls.each do |url|
        message += status.text[index...url.indices.first] + url.attrs[:expanded_url]
        index = url.indices.last
      end
      message += status.text[index..-1]

      CGI.unescapeHTML(message)
    end

    def check_env(env_list)
      target_env = %w(
        TWITTER_CONSUMER_KEY
        TWITTER_CONSUMER_SECRET
        TWITTER_OAUTH_TOKEN
        TWITTER_OAUTH_TOKEN_SECRET
        MASTODON_URL
        MASTODON_ACCESS_TOKEN
      )
      target_env - env_list
    end

    def client
      @client ||= Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
        config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
        config.access_token        = ENV['TWITTER_OAUTH_TOKEN']
        config.access_token_secret = ENV['TWITTER_OAUTH_TOKEN_SECRET']
      end
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
