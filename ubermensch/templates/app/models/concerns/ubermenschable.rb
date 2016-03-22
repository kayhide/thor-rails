module Ubermenschable
  extend ActiveSupport::Concern

  module ClassMethods
    def find_or_create_from_auth_hash auth_hash
      user = find_or_create_by(id: auth_hash.uid) do |new_user|
        new_user.provider = auth_hash.provider
        new_user.uid = new_user.id
      end
      user.update_attributes raw: auth_hash[:info].to_h
      user
    end

    def pull
      res = access_token.get 'api/v1/users'
      json = JSON.parse(res.body)
      json.each do |attrs|
        user = find_or_create_by(id: attrs['id']) do |new_user|
          new_user.provider = 'ubermensch'
          new_user.uid = new_user.id
        end
        user.update_attributes raw: attrs
      end
    end

    def access_token
      @access_token ||=
        begin
          client = OAuth2::Client.new(
            ENV['UBERMENSCH_APP_KEY'],
            ENV['UBERMENSCH_APP_SECRET']
          )
          client.site = ENV['UBERMENSCH_APP_URL']
          client.client_credentials.get_token
        end
    end
  end
end
