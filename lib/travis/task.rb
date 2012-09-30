require 'faraday'
require 'core_ext/hash/compact'
require 'active_support/core_ext/string'

module Travis
  class Task
    autoload :Archive,            'travis/task/archive'
    autoload :Campfire,           'travis/task/campfire'
    autoload :Email,              'travis/task/email'
    autoload :Flowdock,           'travis/task/flowdock'
    autoload :Github,             'travis/task/github'
    autoload :GithubCommitStatus, 'travis/task/github_commit_status'
    autoload :Hipchat,            'travis/task/hipchat'
    autoload :Irc,                'travis/task/irc'
    autoload :Pusher,             'travis/task/pusher'
    autoload :Webhook,            'travis/task/webhook'

    include Logging
    extend  Instrumentation, NewRelic, Exceptions::Handling, Async

    class << self
      def run(type, data, options = {})
        if run_local?
          const_get(type.to_s.camelize).new(data, options).run
        else
          publisher('tasks').publish(:type => type, :data => data, :options => options)
        end
      end

      def run_local?
        Travis::Features.feature_inactive?(:travis_tasks)
      end

      def publisher(queue)
        Travis::Amqp::Publisher.new(queue)
      end
    end

    attr_reader :data, :options

    def initialize(data, options = {})
      @data = data
      @options = options
    end

    def run
      process if process?
    end
    rescues    :run, :from => Exception
    async      :run # unless Travis.env == 'staging'

    def process
      process!
    end
    instrument :process
    new_relic  :process, :category => :task

    def process?
      true
    end

    private

      def http
        @http ||= Faraday.new(http_options) do |f|
          f.request :url_encoded
          f.adapter :net_http
        end
      end

      def http_options
        { :ssl => Travis.config.ssl.compact }
      end
  end
end
