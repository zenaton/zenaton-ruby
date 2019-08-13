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

  describe 'json serialization' do
    let(:object) { 1 / 3r }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
