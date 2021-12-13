# frozen_string_literal: true

require "tac"
require "tac/server"
require "thor"
require "packetfu"

module TAC
  class CLI < Thor
    desc "start", "Begin packet capture and port scan mitigation"

    method_option :iface,
                  default: PacketFu::Utils.default_int,
                  desc: "Specify a network interface to monitor"

    method_option :filter,
                  alias: :bpf,
                  default: "tcp and tcp[tcpflags] == tcp-syn and dst host %<ip_saddr>s",
                  desc: "BPF filter to use when filtering packets"

    method_option :port,
                  default: "8080",
                  desc: "TCP port on which to listen and serve up Prometheus metrics"

    def start
      Thread.new do
        Capture.new(options[:iface], options[:filter]).start
      end

      Rack::Server.start(
        app: TAC::SERVER,
        Host: "0.0.0.0",
        Port: options[:port]
      )
    end

    desc "version", "Print the current version"
    def version
      puts TAC::VERSION
    end
  end
end
