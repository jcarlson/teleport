require 'spec_helper'

RSpec.describe TAC::Models::TTLCollection do
  subject { described_class.new }

  describe '#<<' do
    it 'returns the length of the collection' do
      expect(subject << double).to eq(1)
    end

    it 'stores the same value only once' do
      value = double
      subject << value
      expect(subject << value).to eq(1)
    end

    context 'when items exceeding the TTL exist in the collection' do
      let(:now) { Time.now }

      before do
        Timecop.travel(now - 61) { subject << double }
      end

      it 'removes expired items from the collection' do
        expect(subject << double).to eq(1)
      end
    end
  end

  describe '#values' do
    let(:values) { [double, double, double] }

    before do
      values.each { |value| subject << value }
    end

    it 'returns all items in the collection' do
      expect(subject.values).to eq(values)
    end

    context 'when items exceeding the TTL exist in the collection' do
      let(:now) { Time.now }

      before do
        Timecop.travel(now + 61)
      end

      it 'removes expired items from the collection' do
        expect(subject.values).to eq([])
      end
    end
  end
end
