# frozen_string_literal: true

require 'zenaton/refinements/big_decimal'

RSpec.describe BigDecimal do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject(:props) { BigDecimal(1, 1).zenaton_props }

    it 'returns the internal dump' do
      expect(props['b'].downcase).to eq('27:0.1e1')
    end
  end
end
