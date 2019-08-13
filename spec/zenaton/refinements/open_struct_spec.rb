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

    context 'with a symbol-keyed hash' do
      let(:props) { { 't' => { a: 1 } } }

      it { is_expected.to eq(described_class.new(a: 1)) }
    end

    context 'with a string-keyed hash' do
      let(:props) { { 't' => { 'a' => 1 } } }

      it { is_expected.to eq(described_class.new(a: 1)) }
    end
  end

  describe 'json serialization' do
    let(:object) { described_class.new(a: 1) }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
