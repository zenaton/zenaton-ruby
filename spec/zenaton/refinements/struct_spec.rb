# frozen_string_literal: true

require 'zenaton/refinements/struct'

RSpec.describe Struct do
  using Zenaton::Refinements

  describe '#zenaton_props' do
    subject { Struct::Customer.new(name: 'alice').zenaton_props }

    before { described_class.new('Customer', :name) }

    it { is_expected.to eq('v' => [{ name: 'alice' }]) }
  end
end
