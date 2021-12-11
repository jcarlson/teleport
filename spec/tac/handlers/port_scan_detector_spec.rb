require 'spec_helper'

RSpec.describe TAC::Handlers::PortScanReporter do
  describe '#handle(packet)' do
    let(:now) { Time.new 2021, 12, 11, 14, 00, 00, "-07:00" }

    let(:source_addr) { '1.2.3.4' }
    let(:dest_addr) { '127.0.0.1' }
    let(:packet1) { TAC::Models::Packet.new source_addr, rand(1024..65535), dest_addr, rand(1..65535) }
    let(:packet2) { TAC::Models::Packet.new source_addr, rand(1024..65535), dest_addr, rand(1..65535) }
    let(:packet3) { TAC::Models::Packet.new source_addr, rand(1024..65535), dest_addr, rand(1..65535) }
    let(:packet4) { TAC::Models::Packet.new source_addr, rand(1024..65535), dest_addr, rand(1..65535) }

    subject(:handler) { described_class.new }

    before do
      allow(described_class).to receive(:print)

      # pre-load handler by handling packets 1-3 at T+ :00, :01 and :02 seconds
      [packet1, packet2, packet3].each_with_index do |packet, offset|
        Timecop.travel now + offset
        handler.handle packet
      end
    end

    context 'when single source ip connects to more than 3 host ports in the previous minute' do
      it 'prints a formatted message about the port scan' do
        Timecop.travel now + 10
        handler.handle packet4

        ports = [packet1, packet2, packet3, packet4].map(&:dest_port).sort.join(",")

        expect(described_class).to have_received(:print)
          .with("2021-12-11 21:00:10: Port scan detected: #{source_addr} -> #{dest_addr} on ports #{ports}")
      end
    end

    context 'when single source ip connects to more than 3 host ports in more than a minute' do
      it 'prints a formatted message about the port scan' do
        Timecop.travel now + 70
        handler.handle packet4

        expect(described_class).to_not have_received(:print)
      end
    end
  end
end
