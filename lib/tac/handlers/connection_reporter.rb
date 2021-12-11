module TAC
  module Handlers
    class ConnectionReporter
      def self.print(message)
        puts message
      end

      def handle(packet)
        now = Time.now.utc

        report = '%s: New Connection: %s:%d -> %s:%d' % [
          now.strftime('%Y-%m-%d %H:%M:%S'),
          packet.source_addr,
          packet.source_port,
          packet.dest_addr,
          packet.dest_port
        ]

        self.class.print report
      end
    end
  end
end
