# frozen_string_literal: true

require 'zenaton/refinements/time'

RSpec.describe Time do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { described_class.at(15).to_zenaton }

    it { is_expected.to eq('s' => 15, 'n' => 0) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 's' => 15, 'n' => 0 } }

    it { is_expected.to eq(described_class.at(15)) }
  end
end
