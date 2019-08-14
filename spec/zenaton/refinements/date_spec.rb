# frozen_string_literal: true

require 'zenaton/refinements/date'

RSpec.describe Date do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { described_class.new(2018, 8, 1).to_zenaton }

    let(:expected) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'sg' => 2299161.0
      }
    end

    it { is_expected.to eq(expected) }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) do
      {
        'y' => 2018,
        'm' => 8,
        'd' => 1,
        'sg' => 2299161.0
      }
    end

    it { is_expected.to eq(described_class.new(2018, 8, 1)) }
  end

  describe 'json serialization' do
    let(:object) { described_class.new(2018, 8, 1) }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
