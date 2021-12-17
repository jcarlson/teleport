# frozen_string_literal: true

require "spec_helper"

RSpec.describe TAC::Capture do
  let(:iface) { "lo0" }
  let(:ip_saddr) { "127.0.0.1" }
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

  subject(:capture) { described_class.new iface }

  describe "::new" do
    it "builds a list of handlers" do
      described_class.new iface
      expect(TAC::Handlers)
        .to have_received(:build)
        .with(iface: iface, ifconfig: ifconfig)
    end
  end

  describe "#start" do
    let(:stdout) { object_double($stdout, gets: nil) }

    before do
      allow(Open3)
        .to receive(:popen2)
        .and_yield(double, stdout, double)

      allow(TAC::Packet)
        .to receive(:parse)

      allow(subject)
        .to receive(:system)

      allow(subject)
        .to receive(:at_exit)
    end

    it "configures iptables" do
      capture.start
      expect(subject)
        .to have_received(:system)
        .with("iptables -A INPUT -d #{ip_saddr} -p tcp --syn -j NFLOG --nflog-group 1")
    end

    it "starts a new packet capture" do
      capture.start
      expect(Open3)
        .to have_received(:popen2)
        .with("tcpdump -l -t -n -i nflog:1")
    end

    context "at exit" do
      before do
        allow(subject)
          .to receive(:at_exit) { |&block| block.call }
      end

      it "cleans up iptables" do
        capture.start
        expect(subject)
          .to have_received(:system)
          .with("iptables -D INPUT -d #{ip_saddr} -p tcp --syn -j NFLOG --nflog-group 1")
      end
    end

    context "as packets are captured" do
      let(:stream) { 3.times.map { |n| "IP #{n}.#{n}.#{n}.#{n}.0 > #{n}.#{n}.#{n}.#{n}.65535" } }
      let(:packets) { 3.times.map { instance_double TAC::Packet } }

      before do
        allow(TAC::Packet)
          .to receive(:parse)
          .and_return(*packets)

        allow(stdout)
          .to receive(:gets)
          .and_return(*stream, nil)
      end

      it "parses the raw packets" do
        capture.start

        stream.each do |line|
          expect(TAC::Packet)
            .to have_received(:parse)
            .with(line)
        end
      end

      it "handles each parsed packet" do
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
