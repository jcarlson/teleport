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
      PacketFu::Capture.new(iface: @iface, filter: @filter % @ifconfig, start: true).tap do |capture|
        capture.stream.each do |raw|
          packet = PacketFu::Packet.parse(raw)
          @handlers.each { |handler| handler.handle packet }
        end
      end
    end
  end
end
