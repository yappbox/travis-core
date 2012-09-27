class User
  module Oauth
    extend Travis::Retryable

    class << self
      def find_or_create_by(payload)
        retryable(:tries => 3) do
          attrs = attributes_from(payload)
          user = User.find_by_github_id(attrs['github_id'])
          user ? user.update_attributes(attrs) : user = User.create!(attrs)
          user
        end
      end

      def attributes_from(payload)
        {
          'name'               => payload['info']['name'],
          'email'              => payload['info']['email'],
          'login'              => payload['info']['nickname'],
          'github_id'          => payload['uid'].to_i,
          'github_oauth_token' => payload['credentials']['token'],
          'gravatar_id'        => payload['extra']['raw_info']['gravatar_id']
        }
      end
    end
  end
end
