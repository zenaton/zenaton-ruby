# frozen_string_literal: true

require 'zenaton/refinements/big_decimal'

RSpec.describe BigDecimal do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { BigDecimal(1, 1).zenaton_props }

    it { is_expected.to eq('b' => '27:0.1e1') }
  end
end
