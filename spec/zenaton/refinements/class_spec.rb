# frozen_string_literal: true

require 'zenaton/refinements/class'

RSpec.describe Class do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject(:props) { Integer.to_zenaton }

    it { is_expected.to eq('n' => 'Integer') }
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    let(:props) { { 'n' => 'Integer' } }

    it { is_expected.to eq(Integer) }
  end

  describe 'json serialization' do
    let(:object) { Integer }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
