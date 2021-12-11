require 'spec_helper'

RSpec.describe TAC::Packet do
  let(:source_addr) { '127.0.0.1' }
  let(:source_port) { 65535 }
  let(:dest_addr) { '1.1.1.1' }
  let(:dest_port) { '53' }

  subject { described_class.new source_addr, source_port, dest_addr, dest_port }

  it 'has a source address' do
    expect(subject.source_addr).to eq(source_addr)
  end

  it 'has a source port' do
    expect(subject.source_port).to eq(source_port)
  end

  it 'has a destination address' do
    expect(subject.dest_addr).to eq(dest_addr)
  end

  it 'has a destination port' do
    expect(subject.dest_port).to eq(dest_port)
  end
end
