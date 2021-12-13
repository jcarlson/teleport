require 'tac/ttl_collection'
require 'tac/handlers/base_handler'

module TAC
  module Handlers
    class HostPortScanReporter < BaseHandler
      TTL = 60 # window for tracking new connections

      attr_reader :ifconfig

      def initialize(ifconfig:, **options)
        super
        @ifconfig = ifconfig
        @connections = Hash.new
        @connections.default_proc = -> (hash, key) { hash[key] = TAC::Models::TTLCollection.new(TTL) }
      end

      def handle(packet)
        return unless packet.is_a?(PacketFu::TCPPacket) &&
          packet.tcp_flags.syn == 1 &&
          packet.ip_daddr == ifconfig[:ip_saddr]

        source = packet.ip_saddr

        # record the client connection
        client_connections = @connections[source]
        connection_count = client_connections << packet.tcp_dport

        # print a message if the client has more than three unique port connections in past minute
        if connection_count > 3
          report = 'Port scan detected: %s -> %s on ports %s' % [
            packet.ip_saddr,
            packet.ip_daddr,
            client_connections.values.sort.join(",")
          ]

          log report
          block_source packet.ip_saddr
        end
      end

      private

      def block_source(source)
        rule = "-p tcp -s #{source} -d #{ifconfig[:ip_saddr]} -j DROP"
        system "iptables -A INPUT #{rule}"

        # For the purposes of this code challenge, we will un-block the
        # source IP after a short time, since anyone testing this probably
        # doesn't want to be blocked out forever ;-)
        Thread.new { sleep TTL; system "iptables -D INPUT #{rule}" }
      end
    end
  end
end
