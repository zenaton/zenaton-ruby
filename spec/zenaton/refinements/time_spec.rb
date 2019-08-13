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

  describe 'json serialization' do
    let(:object) { described_class.at(15) }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
