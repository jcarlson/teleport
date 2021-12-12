require 'tac/handlers/base_handler'

module TAC
  module Handlers
    class TcpConnectionReporter < BaseHandler
      def handle(packet)
        return unless packet.is_a?(PacketFu::TCPPacket) &&
          packet.tcp_flags.syn == 1

        report = 'New Connection: %s:%d -> %s:%d' % [
          packet.ip_saddr,
          packet.tcp_sport,
          packet.ip_daddr,
          packet.tcp_dport
        ]

        self.class.print report
      end
    end
  end
end
