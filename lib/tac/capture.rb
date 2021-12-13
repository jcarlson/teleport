# frozen_string_literal: true

require "packetfu"

module TAC
  class Capture
    def initialize(iface, filter)
      @iface = iface
      @filter = filter

      @ifconfig = PacketFu::Utils.whoami?(iface: iface)
      @handlers = TAC::Handlers.build(iface: iface, ifconfig: @ifconfig)
    end

    def start
      bpf = @filter % @ifconfig
      puts "Starting packet capture and DDoS mitigation on #{@iface} with filter #{bpf}"

      PacketFu::Capture.new(iface: @iface, filter: bpf, start: true).tap do |capture|
        capture.stream.each do |raw|
          packet = PacketFu::Packet.parse(raw)
          @handlers.each { |handler| handler.handle packet }
        end
      end
    end
  end
end
