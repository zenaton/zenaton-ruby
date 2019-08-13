# frozen_string_literal: true

require 'zenaton/refinements/symbol'

RSpec.describe Symbol do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { :foobar.to_zenaton }

    it { is_expected.to eq('s' => 'foobar') }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 's' => 'foobar' } }

    it { is_expected.to eq(:foobar) }
  end
end
