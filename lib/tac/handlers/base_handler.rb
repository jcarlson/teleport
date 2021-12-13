module TAC
  module Handlers
    class BaseHandler
      attr_reader :options

      def initialize(**options)
        @options = options
      end

      def handle(packet)
        raise NotImplementedError
      end

      def log(message)
        self.class.log(message)
      end

      def self.inherited(subclass)
        TAC::Handlers.register(subclass)
      end

      def self.log(message)
        puts '%s: %s' % [
          Time.now.utc.strftime('%Y-%m-%d %H:%M:%S'), message
        ]
      end
    end
  end
end
