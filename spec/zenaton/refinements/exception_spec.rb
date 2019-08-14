# frozen_string_literal: true

require 'zenaton/refinements/exception'

RSpec.describe Exception do
  using Zenaton::Refinements

  describe '#to_zenaton' do
    subject { StandardError.new('oops').to_zenaton }

    it { is_expected.to eq('m' => 'oops', 'b' => nil) }
  end

  describe '.from_zenaton' do
    subject { StandardError.from_zenaton(props) }

    let(:props) { { 'm' => 'oops', 'b' => nil } }

    it { is_expected.to eq(StandardError.new('oops')) }
  end

  describe 'json serialization' do
    let(:object) { StandardError.new('oops') }
    let(:props) { object.to_zenaton }
    let(:json) { props.to_json }
    let(:decoded_props) { JSON.parse(json) }
    let(:new_object) { StandardError.from_zenaton(decoded_props) }

    it 'is bijective' do
      expect(new_object).to eq(object)
    end
  end
end
