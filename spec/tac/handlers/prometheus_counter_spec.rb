# frozen_string_literal: true

require "spec_helper"

RSpec.describe TAC::Handlers::PrometheusCounter do
  describe "#handle(packet)" do
    let(:ip_saddr) { "1.2.3.4" }
    let(:tcp_sport) { rand(1..65_535) }
    let(:ip_daddr) { "127.0.0.1" }
    let(:tcp_dport) { rand(1..65_535) }
    let(:tcp_syn) { true }
    let(:packet) do
      TAC::Packet.new ip_saddr, tcp_sport, ip_daddr, tcp_dport
    end

    let(:registry) { instance_double Prometheus::Client::Registry, counter: counter }
    let(:counter) { instance_double Prometheus::Client::Counter, increment: nil }

    subject(:handler) { described_class.new }

    before do
      allow(Prometheus::Client)
        .to receive(:registry)
        .and_return(registry)
    end

    it "increments a count about the new connection" do
      handler.handle packet

      expect(counter).to have_received(:increment)
    end
  end
end
