require 'faraday'
require 'cgi'

module Travis
  class Task
    # Archives a Build to a couchdb once it is finished so we can purge old
    # build data at any time.
    class Archive < Task
      private

        def process
          touch(data) if store(data)
        end

        def store(data)
          url = url_for(data)
          response = http.put(url, data.to_json)
          info "Successfully archived to #{url}."
          response.success?
        rescue Faraday::Error::ClientError => e
          raise Exceptions::FaradayError.new(self, e, :url => url, :raise => true)
        end

        def touch(data)
          # TODO how to deal with this
          build = Build.find_by_id(data['id'])
          build.touch(:archived_at) if build
        end

        def config
          Travis.config.archive
        end

        def url_for(data)
          "http://#{config.username}:#{CGI.escape(config.password)}@#{config.host}/builds/#{data['id']}"
        end

        Notification::Instrument::Task::Archive.attach_to(self)
    end
  end
end
