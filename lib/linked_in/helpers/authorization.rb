module LinkedIn
  module Helpers
    module Authorization

      DEFAULT_OAUTH_OPTIONS = {
        :token_path         => "/uas/oauth2/accessToken",
        :authorize_path     => "/uas/oauth2/authorization",
        :api_host           => "https://api.linkedin.com",
        :auth_host          => "https://www.linkedin.com"
      }

      def consumer
        @consumer ||= ::OAuth2::Client.new(@consumer_token, @consumer_secret, parse_oauth_options)
      end

      def authorize_from_request(code, params = {})
        token = consumer.auth_code.get_token(code, params)
        @auth_token = token.token
        token
      end

      def access_token
        @access_token ||= ::OAuth2::AccessToken.new(consumer, @auth_token)
      end

      def authorize_url(params = {})
        consumer.auth_code.authorize_url(params)
      end

      def authorize_from_access(atoken)
        @auth_token = atoken
      end

      private

      def parse_oauth_options
        {
          :token_url         => full_oauth_url_for(:token,     :api_host),
          :authorize_url     => full_oauth_url_for(:authorize, :auth_host),
          :site              => @consumer_options[:site] || @consumer_options[:api_host] || DEFAULT_OAUTH_OPTIONS[:api_host],
          :raise_errors      => false
        }
      end

      def full_oauth_url_for(url_type, host_type)
        if @consumer_options["#{url_type}_url".to_sym]
          @consumer_options["#{url_type}_url".to_sym]
        else
          host = @consumer_options[:site] || @consumer_options[host_type] || DEFAULT_OAUTH_OPTIONS[host_type]
          path = @consumer_options[:"#{url_type}_path".to_sym] || DEFAULT_OAUTH_OPTIONS["#{url_type}_path".to_sym]
          "#{host}#{path}"
        end
      end
    end
  end
end
