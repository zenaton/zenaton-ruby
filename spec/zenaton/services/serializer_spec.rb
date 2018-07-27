# frozen_string_literal: true

require 'zenaton/services/serializer'
require 'fixtures/serialize_me'

RSpec.describe Zenaton::Services::Serializer do
  let(:serializer) { described_class.new }

  describe '#encode' do
    let(:encoded) { serializer.encode(data) }
    let(:parsed_json) { JSON.parse(encoded) }

    context 'with a string' do
      let(:data) { 'e' }

      it 'represents the string as a data' do
        expect(parsed_json).to eq('d' => 'e', 's' => [])
      end
    end

    context 'with an integer' do
      let(:data) { 1 }

      it 'represents the integer as a data' do
        expect(parsed_json).to eq('d' => 1, 's' => [])
      end
    end

    context 'with true' do
      let(:data) { true }

      it 'represents the boolean as a data' do
        expect(parsed_json).to eq('d' => true, 's' => [])
      end
    end

    context 'with false' do
      let(:data) { false }

      it 'represents the boolean as a data' do
        expect(parsed_json).to eq('d' => false, 's' => [])
      end
    end

    context 'with nil' do
      let(:data) { nil }

      it 'represents the boolean as a data' do
        expect(parsed_json).to eq('d' => nil, 's' => [])
      end
    end

    context 'with a proc' do
      let(:data) { proc { |x| puts x } }

      it 'raises an exception' do
        expect { parsed_json }.to raise_error ArgumentError
      end
    end

    context 'with an array' do
      let(:data) { [1, 'e'] }

      it 'represents the array as an array' do
        expect(parsed_json).to eq('a' => [1, 'e'], 's' => [])
      end
    end

    context 'with a hash' do
      let(:data) { { 'key' => 'value' } }

      it 'represents the hash as an array' do
        expect(parsed_json).to \
          eq('a' => { 'key' => 'value' }, 's' => [])
      end
    end

    context 'with a simple object' do
      let(:data) { SerializeMe.new }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [
            {
              'n' => 'SerializeMe',
              'p' => {
                '@initialized' => true
              }
            }
          ]
        }
      end

      it 'represents the object as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with an object with circular dependencies' do
      let(:data) { SerializeCircular::Parent.new }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [
            {
              'n' => 'SerializeCircular::Parent',
              'p' => {
                '@child' => '@zenaton#1'
              }
            }, {
              'n' => 'SerializeCircular::Child',
              'p' => {
                '@parent' => '@zenaton#0'
              }
            }
          ]
        }
      end

      it 'represents the object as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end
  end
end
