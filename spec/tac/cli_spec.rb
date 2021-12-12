require 'spec_helper'
require 'tac/cli'

RSpec.describe TAC::CLI do
  let(:iface) { double }
  let(:filter) { double }
  let(:args) { Array.new }
  let(:options) { { iface: iface, filter: filter} }

  subject(:cli) { described_class.new args, options }

  describe '#start' do
    let(:capture) { instance_double TAC::Capture, start: nil }

    before do
      allow(TAC::Capture)
        .to receive(:new)
          .and_return(capture)
    end

    it 'creates a new capture' do
      cli.start

      expect(TAC::Capture)
        .to have_received(:new)
          .with iface, filter
    end

    it 'starts the capture' do
      cli.start

      expect(capture)
        .to have_received(:start)
    end
  end

  describe '#version' do
    before do
      allow($stdout)
        .to receive(:puts)
    end

    it 'prints the current version' do
      cli.version

      expect($stdout)
        .to have_received(:puts)
          .with(TAC::VERSION)
    end
  end
end
