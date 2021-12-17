# frozen_string_literal: true

require "open3"
require "packetfu"
require "tac/packet"

module TAC
  class Capture
    def initialize(iface)
      @iface = iface

      @ifconfig = PacketFu::Utils.whoami?(iface: iface)
      @handlers = TAC::Handlers.build(iface: iface, ifconfig: @ifconfig)
    end

    def start
      puts "Starting packet capture and DDoS mitigation on #{@iface}"

      rule = "-d #{@ifconfig[:ip_saddr]} -p tcp --syn -j NFLOG --nflog-group 1"
      system "iptables -A INPUT #{rule}"
      at_exit { system "iptables -D INPUT #{rule}" }

      Open3.popen2("tcpdump -l -t -n -i nflog:1") do |_stdin, stdout, _thread|
        until (line = stdout.gets).nil?
          next unless line.start_with? "IP"

          packet = TAC::Packet.parse(line)
          @handlers.each { |handler| handler.handle packet }
        end
      end
    end
  end
end
