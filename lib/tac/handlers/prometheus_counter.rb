# frozen_string_literal: true

require "tac/handlers/base_handler"
require "prometheus/client"

module TAC
  module Handlers
    class PrometheusCounter < BaseHandler
      def initialize(**_)
        super

        Prometheus::Client.registry.tap do |prometheus|
          @counter = prometheus.counter(:tcp_syn_packets, docstring: "A counter of TCP-SYN packets")
        end
      end

      def handle(_)
        @counter.increment
      end
    end
  end
end
