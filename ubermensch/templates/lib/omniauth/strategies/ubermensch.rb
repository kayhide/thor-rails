module OmniAuth
  module Strategies
    class Ubermensch < OmniAuth::Strategies::OAuth2
      option :name, :ubermensch

      option :client_options, {
        site: ENV['UBERMENSCH_APP_URL'],
        authorize_path: '/oauth/authorize'
      }

      uid do
        raw_info['id']
      end

      info do
        raw_info
      end

      def raw_info
        @raw_info ||= access_token.get('/api/v1/account.json').parsed
      end
    end
  end
end
