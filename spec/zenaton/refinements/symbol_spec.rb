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

  describe 'json serialization' do
    let(:object) { :foo }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
