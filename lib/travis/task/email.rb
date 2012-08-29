require 'core_ext/module/include'
require 'net/smtp'

module Travis
  class Task

    # Sends out build notification emails using ActionMailer.
    class Email < Task
      include Logging

      def recipients
        options[:recipients]
      end

      def type
        :"#{data['build']['state']}_email"
      end

      private

        def process
          Travis::Mailer::Build.send(type, data, recipients).deliver
        rescue Postmark::InvalidMessageError => e
          raise Exceptions::ClientError.new(self, e)
        end

        Notification::Instrument::Task::Email.attach_to(self)
    end
  end
end
