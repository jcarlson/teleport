module TAC
  module Handlers
    class BaseHandler
      attr_reader :options

      def initialize(**options)
        @options = options
      end

      def self.print(message)
        puts '%s: %s' % [
          Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'), message
        ]
      end
    end
  end
end
