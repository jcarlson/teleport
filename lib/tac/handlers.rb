module TAC
  module Handlers
    @klasses = []

    def self.build(**options)
      @klasses.map { |klass| klass.new **options }
    end

    def self.register(handler_klass)
      @klasses << handler_klass
    end
  end
end

require 'tac/handlers/tcp_connection_reporter'
require 'tac/handlers/host_port_scan_reporter'
require 'tac/handlers/prometheus_counter'
