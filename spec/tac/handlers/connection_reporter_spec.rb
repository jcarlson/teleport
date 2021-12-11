require 'spec_helper'

RSpec.describe TAC::Handlers::ConnectionReporter do
  describe '#handle(packet)' do
    let(:source_addr) { '127.0.0.1' }
    let(:source_port) { rand(1..65535) }
    let(:dest_addr) { '1.2.3.4' }
    let(:dest_port) { rand(1..65535) }
    let(:packet) { TAC::Models::Packet.new source_addr, source_port, dest_addr, dest_port }
    let(:now) { Time.new 2021, 12, 11, 14, 00, 00, "-07:00" }

    subject(:handler) { described_class.new }

    before do
      Timecop.freeze now

      allow(described_class).to receive(:print)
    end

    it 'prints a formatted message about the new connection' do
      handler.handle packet

      expect(described_class).to have_received(:print)
        .with("2021-12-11 21:00:00: New Connection: #{source_addr}:#{source_port} -> #{dest_addr}:#{dest_port}")
    end
  end
end
