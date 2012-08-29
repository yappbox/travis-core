require 'faraday'
require 'core_ext/hash/compact'
require 'active_support/core_ext/string'

module Travis
  class Task
    autoload :Archive,            'travis/task/archive'
    autoload :Campfire,           'travis/task/campfire'
    autoload :Email,              'travis/task/email'
    autoload :Exceptions,         'travis/task/exceptions'
    autoload :Github,             'travis/task/github'
    autoload :GithubCommitStatus, 'travis/task/github_commit_status'
    autoload :Hipchat,            'travis/task/hipchat'
    autoload :Irc,                'travis/task/irc'
    autoload :Pusher,             'travis/task/pusher'
    autoload :Webhook,            'travis/task/webhook'

    include Logging
    extend  Instrumentation, NewRelic, Travis::Exceptions::Handling, Async

    class << self
      def run(type, data, options = {})
        if false && Travis.env == 'staging'
          publisher('tasks').publish(:data => data, :options => options)
        else
          const_get(type.to_s.camelize).new(data, options).run
        end
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
      process
    rescue Exceptions::ClientError => e
      error(e.message)
      raise(e) if e.raise?
      # TODO somehow add a note to the build if this task is triggered from .travis.yml
    end

    rescues    :run, :from => Exception
    instrument :run
    new_relic  :run, :category => :task
    async      :run # unless Travis.env == 'staging'

    private

      def http
        @http ||= Faraday.new(http_options) do |f|
          f.request :url_encoded
          f.response :raise_error
          f.adapter :net_http
        end
      end

      def http_options
        { :ssl => Travis.config.ssl.compact }
      end
  end
end
