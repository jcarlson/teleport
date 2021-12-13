# frozen_string_literal: true

require "tac/handlers/base_handler"

module TAC
  module Handlers
    class TcpConnectionReporter < BaseHandler
      def handle(packet)
        return unless packet.is_a?(PacketFu::TCPPacket) &&
                      packet.tcp_flags.syn == 1

        report = format(
          "New Connection: %<source_ip>s:%<source_port>d -> %<dest_ip>s:%<dest_port>d",
          source_ip: packet.ip_saddr,
          source_port: packet.tcp_sport,
          dest_ip: packet.ip_daddr,
          dest_port: packet.tcp_dport
        )

        log report
      end
    end
  end
end
