# frozen_string_literal: true

require 'zenaton/refinements/rational'

RSpec.describe Rational do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { (1 / 3r).to_zenaton }

    it { is_expected.to eq('n' => 1, 'd' => 3) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 'n' => 1, 'd' => 3 } }

    it { is_expected.to eq(1 / 3r) }
  end
end
