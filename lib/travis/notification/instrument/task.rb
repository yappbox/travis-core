module Travis
  module Notification
    class Instrument
      class Task < Instrument
        class Archive < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['id']
            )
          end
        end

        class Campfire < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request']['id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Flowdock < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request']['id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Hipchat < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request']['id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :targets => task.targets,
              :message => task.message
            )
          end
        end

        class Email < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :email => task.type,
              :recipients => task.recipients
            )
          end
        end

        class Github < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :url => task.url,
              :message => task.message
            )
          end
        end

        class GithubCommitStatus < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :url => task.full_url.to_s
            )
          end
        end

        class Irc < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['build']['id']}>",
              :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['build']['id'],
              :channels => task.channels,
              :messages => task.messages
            )
          end
        end

        class Pusher < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<#{type.camelize} id=#{id}> (channels: #{task.channels.join(', ')})",
              # :repository => data['repository']['slug'],
              # :request_id => data['request_id'], # TODO
              :object_type => type.camelize,
              :object_id => id,
              :event => task.event,
              :client_event => task.client_event,
              :channels => task.channels
            ) unless task.event.to_s == 'job:test:log'
          end

          def type
            @type ||= task.event.split(':').first
          end

          def id
            # TODO ugh. should be better with API v2
            data.key?(type) ? data[type]['id'] : data['id']
          end
        end

        class Webhook < Task
          def process_completed
            publish(
              :msg => "#{task.class.name}#process for #<Build id=#{data['id']}>",
              :repository => data['repository'].values_at(*%w(owner_name name)).join('/'),
              # :request_id => data['request_id'], # TODO
              :object_type => 'Build',
              :object_id => data['id'],
              :targets => task.targets
            )
          end
        end

        attr_reader :task, :data

        def initialize(message, status, payload)
          @task = payload[:target]
          @data = task.data
          super
        end

        def process_completed
          publish
        end

        def publish(event = {})
          super(event.merge(:data => self.data))
        end
      end
    end
  end
end
