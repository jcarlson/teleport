require 'spec_helper'

RSpec.describe TAC::Capture do
  let(:iface) { 'lo0' }
  let(:filter) { 'tcp and dst host %{ip_saddr}' }
  let(:ip_saddr) { '127.0.0.1' }
  let(:ifconfig) { { iface: iface, ip_saddr: ip_saddr } }
  let(:handlers) { [instance_double(TAC::Handlers::BaseHandler, handle: nil)] }

  before do
    allow(PacketFu::Utils)
      .to receive(:whoami?)
        .and_return(ifconfig)

    allow(TAC::Handlers)
      .to receive(:build)
        .and_return(handlers)
  end

  subject(:capture) { described_class.new iface, filter }

  describe '::new' do
    it 'builds a list of handlers' do
      described_class.new iface, filter
      expect(TAC::Handlers)
        .to have_received(:build)
          .with(iface: iface, ifconfig: ifconfig)
    end
  end

  describe '#start' do
    let(:pcap) { instance_double(PacketFu::Capture, stream: stream) }
    let(:stream) { Array.new }

    before do
      allow(PacketFu::Capture)
        .to receive(:new)
          .and_return(pcap)
    end

    it 'starts a new packet capture' do
      capture.start
      expect(PacketFu::Capture)
        .to have_received(:new)
          .with hash_including start: true, iface: iface
    end

    it 'interpolates the bpf filter' do
      capture.start
      expect(PacketFu::Capture)
        .to have_received(:new)
          .with hash_including filter: "tcp and dst host #{ip_saddr}"
    end

    context 'when packets are captured' do
      let(:stream) { 3.times.map { double } }
      let(:packets) { 3.times.map { instance_double PacketFu::Packet } }

      before do
        allow(PacketFu::Packet)
          .to receive(:parse)
            .and_return(*packets)

      end

      it 'parses the raw packets' do
        capture.start

        stream.each do |raw_packet|
          expect(PacketFu::Packet)
            .to have_received(:parse)
              .with(raw_packet)
        end
      end

      it 'handles each parsed packet' do
        capture.start

        packets.each do |packet|
          handlers.each do |handler|
            expect(handler)
              .to have_received(:handle)
                .with(packet)
          end
        end
      end
    end
  end
end
