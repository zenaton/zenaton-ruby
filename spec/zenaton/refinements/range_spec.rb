# frozen_string_literal: true

require 'zenaton/refinements/range'

RSpec.describe Range do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    context 'with upper limit included' do
      subject { (1..5).to_zenaton }

      it { is_expected.to eq('a' => [1, 5, false]) }
    end

    context 'with upper limit excluded' do
      subject { (1...5).to_zenaton }

      it { is_expected.to eq('a' => [1, 5, true]) }
    end
  end

  describe '.from_zenaton' do
    subject { described_class.from_zenaton(props) }

    context 'with upper limit included' do
      let(:props) { { 'a' => [1, 5, false] } }

      it { is_expected.to eq(1..5) }
    end

    context 'with upper limit excluded' do
      let(:props) { { 'a' => [1, 5, true] } }

      it { is_expected.to eq(1...5) }
    end
  end

  describe 'json serialization' do
    let(:object) { 1..5 }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { described_class.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
