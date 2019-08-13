# frozen_string_literal: true

require 'zenaton/refinements/open_struct'

RSpec.describe OpenStruct do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { described_class.new(a: 1).to_zenaton }

    it { is_expected.to eq('t' => { a: 1 }) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 't' => { a: 1 } } }

    it { is_expected.to eq(described_class.new(a: 1)) }
  end
end
