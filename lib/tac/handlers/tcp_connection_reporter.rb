# frozen_string_literal: true

require "tac/handlers/base_handler"

module TAC
  module Handlers
    class TcpConnectionReporter < BaseHandler
      def handle(packet)
        report = format(
          "New Connection: %<source_ip>s:%<source_port>d -> %<dest_ip>s:%<dest_port>d",
          source_ip: packet.s_addr,
          source_port: packet.s_port,
          dest_ip: packet.d_addr,
          dest_port: packet.d_port
        )

        log report
      end
    end
  end
end
