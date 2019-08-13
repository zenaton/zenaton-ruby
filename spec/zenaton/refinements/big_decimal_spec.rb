# frozen_string_literal: true

require 'zenaton/refinements/big_decimal'

RSpec.describe BigDecimal do
  using Zenaton::Refinements

  describe "#zenaton_properties" do
    subject { BigDecimal(1, 1).zenaton_properties }

    it { is_expected.to eq(
      'b' => '27:0.1e1'
    ) }
  end
end
