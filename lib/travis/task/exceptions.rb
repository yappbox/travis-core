module Travis
  class Task
    module Exceptions
      class ClientError < StandardError
        attr_reader :task, :error, :metadata

        def initialize(task, error, options = nil)
          @task = task
          @error = error
          @raise = options.is_a?(Hash) ? options.delete(:raise) : false
          @metadata = options
        end

        def raise?
          !!@raise
        end

        def message
          "[task] #{task.class.name}: (#{error.class.name}) #{error.message}"
        end

        def backtrace
          error.backtrace
        end
      end

      class FaradayError < ClientError
        def message
          message = "#{super} (#{metadata[:url]})"
          message = "#{message}: #{error.response[:status]} #{error.response[:body]}" if error.response
          message
        end
      end

      class GHError < ClientError
        def message
          message = "#{super} (#{metadata[:url]})"
          message = "#{message}: #{error.info[:response_status]} #{error.info[:response_body]}" if error.info[:response_status]
          message
        end
      end
    end
  end
end
