require 'json'

module Travis
  class Task

    # Sends build notifications to webhooks as defined in the configuration
    # (`.travis.yml`).
    class Webhook < Task
      def targets
        options[:targets]
      end

      private

        def process
          targets.each { |target| send_webhook(target) }
        end

        def send_webhook(url)
          response = http.post(url) do |req|
            req.body = { :payload => data.to_json }
            req.headers['Authorization'] = authorization
          end
          info "Successfully notified #{url}."
        rescue Faraday::Error::ClientError => e
          raise Exceptions::FaradayError.new(self, e, :url => url)
        end

        def authorization
          Digest::SHA2.hexdigest(data['repository'].values_at('owner_name', 'name').join('/') + options[:token])
        end

        Notification::Instrument::Task::Webhook.attach_to(self)
    end
  end
end
