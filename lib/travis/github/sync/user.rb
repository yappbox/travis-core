require 'core_ext/module/include'

module Travis
  module Github
    class Sync
      class User
        attr_reader :user

        def initialize(user)
          @user = user
        end

        def run
          if can_sync?
            syncing do
              Organizations.new(user).run
              Repositories.new(user).run
            end
          end
        end

        def can_sync?
          !user.syncing? && rate_limit_remaining > 1000
        end

        def syncing
          user.update_attribute :is_syncing, true
          result = yield
          user.update_attribute :synced_at, Time.now
          result
        ensure
          user.update_attribute :is_syncing, false
        end

        def rate_limit_remaining
          GH["users/#{user.login}"].headers['x-ratelimit-remaining'].to_i
        rescue Faraday::Error::ResourceNotFound => e
          user.destroy # TODO is this what we want?
          0
        rescue Faraday::Error::ClientError => e
          0
        end
      end
    end
  end
end
