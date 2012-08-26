module Travis
  module Github
    class Sync
      autoload :Organizations, 'travis/github/sync/organizations'
      autoload :Repositories,  'travis/github/sync/repositories'
      autoload :Repository,    'travis/github/sync/repository'
      autoload :User,          'travis/github/sync/user'

      attr_reader :options

      def initialize(options = {})
        @options = options
      end

      def run
        users.each { |user| user.sync }
      end

      def users
        ::User.order('synced_at').limit(options[:count] || Travis.config.sync.count)
      end
    end
  end
end
