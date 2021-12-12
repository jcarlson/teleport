require 'tac'
require 'thor'
require 'packetfu'

module TAC
  class CLI < Thor
    desc 'start', 'Begin packet capture and port scan mitigation'

    method_option :iface,
      default: PacketFu::Utils.default_int,
      desc: 'Specify a network interface to monitor'

    method_option :filter,
      alias: :bpf,
      default: 'tcp and tcp[tcpflags] == tcp-syn and dst host %{ip_saddr}',
      desc: 'BPF filter to use when filtering packets'

    def start
      Capture.new(options[:iface], options[:filter]).start
    end

    desc 'version', 'Print the current version'
    def version
      puts TAC::VERSION
    end
  end
end
