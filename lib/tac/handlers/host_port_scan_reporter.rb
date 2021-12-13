# frozen_string_literal: true

require "tac/ttl_collection"
require "tac/handlers/base_handler"

module TAC
  module Handlers
    class HostPortScanReporter < BaseHandler
      TTL = 60 # window for tracking new connections

      attr_reader :ifconfig

      def initialize(ifconfig:, **options)
        super
        @ifconfig = ifconfig
        @connections = {}
        @connections.default_proc = ->(hash, key) { hash[key] = TAC::Models::TTLCollection.new(TTL) }
      end

      def handle(packet)
        return unless packet.is_a?(PacketFu::TCPPacket) &&
                      packet.tcp_flags.syn == 1 &&
                      packet.ip_daddr == ifconfig[:ip_saddr]

        source = packet.ip_saddr

        # record the client connection
        client_connections = @connections[source]
        connection_count = client_connections << packet.tcp_dport

        return unless connection_count > 3

        log_port_scan(client_connections, packet)
        block_source packet.ip_saddr
      end

      private

      def log_port_scan(client_connections, packet)
        # print a message if the client has more than three unique port connections in past minute
        message = format(
          "Port scan detected: %<source>s -> %<destination>s on ports %<ports>s",
          source: packet.ip_saddr,
          destination: packet.ip_daddr,
          ports: client_connections.values.sort.join(",")
        )

        log message
      end

      def block_source(source)
        rule = "-p tcp -s #{source} -d #{ifconfig[:ip_saddr]} -j DROP"

        # `system` does not raise an error if the system call fails, so if you don't have iptables installed,
        # this just won't do anything. In a production environment, we could pretty easily manage the system dependencies
        # so I haven't spent any time here checking if this call "worked".
        system "iptables -A INPUT #{rule}"

        # For the purposes of this code challenge, we will un-block the
        # source IP after a short time, since anyone testing this probably
        # doesn't want to be blocked out forever ;-)
        Thread.new do
          sleep TTL
          system "iptables -D INPUT #{rule}"
        end
      end
    end
  end
end
