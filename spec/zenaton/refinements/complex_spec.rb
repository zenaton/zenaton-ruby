# frozen_string_literal: true

require 'zenaton/refinements/complex'

RSpec.describe Complex do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { (1 + 2i).to_zenaton }

    it { is_expected.to eq('r' => 1, 'i' => 2) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 'r' => 1, 'i' => 2 } }

    it { is_expected.to eq(1 + 2i) }
  end

  describe 'json serialization' do
    let(:object) { 1 + 2i }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
