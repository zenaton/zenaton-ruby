# frozen_string_literal: true

require 'zenaton/refinements/range'

RSpec.describe Range do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    context 'with upper limit included' do
      subject { (1..5).to_zenaton }

      it { is_expected.to eq('a' => [1, 5, false]) }
    end

    context 'with upper limit excluded' do
      subject { (1...5).to_zenaton }

      it { is_expected.to eq('a' => [1, 5, true]) }
    end
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    context 'with upper limit included' do
      let(:props) { { 'a' => [1, 5, false] } }

      it { is_expected.to eq(1..5) }
    end

    context 'with upper limit excluded' do
      let(:props) { { 'a' => [1, 5, true] } }

      it { is_expected.to eq(1...5) }
    end
  end
end
