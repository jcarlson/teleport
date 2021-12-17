# frozen_string_literal: true

require "spec_helper"

RSpec.describe TAC::Handlers::TcpConnectionReporter do
  describe "#handle(packet)" do
    let(:ip_saddr) { "1.2.3.4" }
    let(:tcp_sport) { rand(1..65_535) }
    let(:ip_daddr) { "127.0.0.1" }
    let(:tcp_dport) { rand(1..65_535) }
    let(:tcp_syn) { true }
    let(:packet) do
      TAC::Packet.new ip_saddr, tcp_sport, ip_daddr, tcp_dport
    end

    subject(:handler) { described_class.new }

    before do
      allow(described_class).to receive(:log)
    end

    it "prints a formatted message about the new connection" do
      handler.handle packet

      expect(described_class).to have_received(:log)
        .with("New Connection: #{ip_saddr}:#{tcp_sport} -> #{ip_daddr}:#{tcp_dport}")
    end
  end
end
