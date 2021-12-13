require 'spec_helper'

RSpec.describe TAC::Handlers::HostPortScanReporter do
  describe '#handle(packet)' do
    let(:source_addr) { '1.2.3.4' }
    let(:dest_addr) { '127.0.0.1' }
    let(:tcp_syn) { true }
    let(:ifconfig) { { ip_saddr: '127.0.0.1' } }

    let(:packets) do
      4.times.map do
        PacketFu::TCPPacket.new.tap do |pkt|
          pkt.ip_saddr = source_addr
          pkt.tcp_sport = rand(1024..65535)
          pkt.ip_daddr = dest_addr
          pkt.tcp_dport = rand(1024..65535)
          pkt.tcp_flags = PacketFu::TcpFlags.new syn: tcp_syn
        end
      end
    end

    subject(:handler) { described_class.new ifconfig: ifconfig }

    before do
      Timecop.freeze
      allow(described_class)
        .to receive(:log)

      allow(subject)
        .to receive(:system)

      # pre-load handler by handling packets 1-3 at T-minus :03, :02 and :01 seconds
      packets[0..-2].each_with_index do |packet, offset|
        t_minus = packets.length - offset - 1
        # go back in time and handle the packet
        Timecop.freeze(Time.now - t_minus) do
          handler.handle packet
        end
      end
    end

    context 'when packet is not a TCPPacket' do
      let(:packets) { 4.times.map { PacketFu::InvalidPacket.new } }

      it 'ignores packet' do
        handler.handle packets.last
        expect(described_class).to_not have_received(:log)
      end
    end

    context 'when packet is not a TCP-SYN packet' do
      let(:tcp_syn) { false }

      it 'ignores packet' do
        handler.handle packets.last
        expect(described_class).to_not have_received(:log)
      end
    end

    context 'when packet is not destined for host interface' do
      let(:dest_addr) { '192.168.1.1' }

      it 'ignores packet' do
        handler.handle packets.last
        expect(described_class).to_not have_received(:log)
      end
    end

    context 'when source ip connects to more than 3 host ports in more than a minute' do
      it 'prints a formatted message about the port scan' do
        Timecop.freeze(Time.now + 70)
        handler.handle packets.last

        expect(described_class).to_not have_received(:log)
      end
    end

    context 'when source ip connects to more than 3 host ports in the previous minute' do
      it 'prints a formatted message about the port scan' do
        handler.handle packets.last

        ports = packets.map(&:tcp_dport).sort.join(",")

        expect(described_class).to have_received(:log)
          .with("Port scan detected: #{source_addr} -> #{dest_addr} on ports #{ports}")
      end

      it 'configures a firewall rule to block client' do
        handler.handle packets.last

        expect(subject)
          .to have_received(:system)
            .with("iptables -A INPUT -p tcp -s #{source_addr} -d #{dest_addr} -j DROP")
      end
    end
  end
end
