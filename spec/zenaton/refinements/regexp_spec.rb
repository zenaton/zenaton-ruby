# frozen_string_literal: true

require 'zenaton/refinements/regexp'

RSpec.describe Regexp do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    context 'with options' do
      subject { /[a-z]/i.to_zenaton }

      it { is_expected.to eq('o' => 1, 's' => '[a-z]') }
    end

    context 'without options' do
      subject { /(.)+/.to_zenaton }

      it { is_expected.to eq('o' => 0, 's' => '(.)+') }
    end
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 'o' => 1, 's' => '[a-z]' } }

    it { is_expected.to eq(/[a-z]/i) }
  end
end
