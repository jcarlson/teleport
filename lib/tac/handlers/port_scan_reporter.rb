require 'tac/models/ttl_collection'

module TAC
  module Handlers
    class PortScanReporter
      TTL = 60 # window for tracking new connections

      def self.print(message)
        puts message
      end

      def initialize
        @connections = Hash.new
        @connections.default_proc = -> (hash, key) { hash[key] = TAC::Models::TTLCollection.new(TTL) }
      end

      def handle(packet)
        source = packet.source_addr

        # record the client connection
        client_connections = @connections[source]
        connection_count = client_connections << packet.dest_port

        # print a message if the client has more than three unique port connections in past minute
        if connection_count > 3
          now = Time.now.utc

          report = '%s: Port scan detected: %s -> %s on ports %s' % [
            now.strftime('%Y-%m-%d %H:%M:%S'),
            packet.source_addr,
            packet.dest_addr,
            client_connections.values.sort.join(",")
          ]

          self.class.print report
        end
      end
    end
  end
end
