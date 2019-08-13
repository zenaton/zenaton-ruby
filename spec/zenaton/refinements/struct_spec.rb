# frozen_string_literal: true

require 'zenaton/refinements/struct'

RSpec.describe Struct do
  using Zenaton::Refinements

  before { described_class.new('Customer', :name) }

  describe '#to_zenaton' do
    subject { Struct::Customer.new(name: 'alice').to_zenaton }

    it { is_expected.to eq('v' => [{ name: 'alice' }]) }
  end

  describe '.from_zenaton' do
    subject { Struct::Customer.from_zenaton(props) }

    let(:props) { { 'v' => [{ name: 'alice' }] } }

    it { is_expected.to eq(Struct::Customer.new(name: 'alice')) }
  end
end
