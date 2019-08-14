# frozen_string_literal: true

require 'zenaton/refinements/struct'

RSpec.describe Struct do
  using Zenaton::Refinements

  before { described_class.new('Customer', :name) }

  describe '#to_zenaton' do
    context 'with a named struct' do
      subject { Struct::Customer.new('alice').to_zenaton }

      it { is_expected.to eq('v' => ['alice']) }
    end

    context 'with an anonymous struct' do
      subject(:struct) { described_class.new(:name).new('alice') }

      it 'raises an error' do
        expect { struct.to_zenaton }.to raise_error ArgumentError
      end
    end
  end

  describe '.from_zenaton' do
    subject { Struct::Customer.from_zenaton(props) }

    let(:props) { { 'v' => ['alice'] } }

    it { is_expected.to eq(Struct::Customer.new('alice')) }
  end

  describe 'json serialization' do
    let(:object) { Struct::Customer.new('alice') }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { Struct::Customer.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
