# frozen_string_literal: true

require 'zenaton/refinements/big_decimal'

RSpec.describe BigDecimal do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject(:props) { BigDecimal(1, 1).to_zenaton }

    it 'returns the internal dump' do
      expect(props['b'].downcase).to eq('27:0.1e1')
    end
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 'b' => '27:0.1e1' } }

    it { is_expected.to eq(BigDecimal(1, 1)) }
  end
end
