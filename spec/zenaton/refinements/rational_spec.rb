# frozen_string_literal: true

require 'zenaton/refinements/rational'

RSpec.describe Rational do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { (1 / 3r).zenaton_props }

    it { is_expected.to eq('n' => 1, 'd' => 3) }
  end
end
