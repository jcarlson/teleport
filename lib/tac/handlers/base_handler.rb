# frozen_string_literal: true

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
        super
        TAC::Handlers.register(subclass)
      end

      def self.log(message)
        msg = format(
          "%<timestamp>s: %<message>s",
          timestamp: Time.now.utc.strftime("%Y-%m-%d %H:%M:%S"),
          message: message
        )

        puts msg
      end
    end
  end
end
