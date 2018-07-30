# frozen_string_literal: true

require 'zenaton/services/serializer'
require 'fixtures/serialize_me'

RSpec.describe Zenaton::Services::Serializer do
  let(:serializer) { described_class.new }

  describe '#encode' do
    let(:encoded) { serializer.encode(data) }

    context 'with a string' do
      let(:data) { 'e' }

      it 'represents the string as a data' do
        expect(encoded).to eq('d' => 'e', 's' => [])
      end
    end

    context 'with an integer' do
      let(:data) { 1 }

      it 'represents the integer as a data' do
        expect(encoded).to eq('d' => 1, 's' => [])
      end
    end

    context 'with a float' do
      let(:data) { 1.8 }

      it 'represents the float as a data' do
        expect(encoded).to eq('d' => 1.8, 's' => [])
      end
    end

    context 'with true' do
      let(:data) { true }

      it 'represents the boolean as a data' do
        expect(encoded).to eq('d' => true, 's' => [])
      end
    end

    context 'with false' do
      let(:data) { false }

      it 'represents the boolean as a data' do
        expect(encoded).to eq('d' => false, 's' => [])
      end
    end

    context 'with nil' do
      let(:data) { nil }

      it 'represents the boolean as a data' do
        expect(encoded).to eq('d' => nil, 's' => [])
      end
    end

    context 'with a proc' do
      let(:data) { proc { |x| puts x } }

      it 'raises an exception' do
        expect { encoded }.to raise_error ArgumentError
      end
    end

    context 'with an array' do
      let(:data) { [1, 'e'] }

      it 'represents the array as an array' do
        expect(encoded).to eq('a' => [1, 'e'], 's' => [])
      end
    end

    context 'with a hash' do
      let(:data) { { 'key' => 'value' } }

      it 'represents the hash as an array' do
        expect(encoded).to \
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
                :@initialized => true
              }
            }
          ]
        }
      end

      it 'represents the object as an object' do
        expect(encoded).to eq(expected_representation)
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
                :@child => '@zenaton#1'
              }
            }, {
              'n' => 'SerializeCircular::Child',
              'p' => {
                :@parent => '@zenaton#0'
              }
            }
          ]
        }
      end

      it 'represents the object as an object' do
        expect(encoded).to eq(expected_representation)
      end
    end
  end

  describe '#decode' do
    let(:decoded) { serializer.decode(json) }

    context 'with a string do' do
      let(:json) { { 'd' => 'e', 's' => [] } }

      it 'returns the string' do
        expect(decoded).to eq('e')
      end
    end

    context 'with an integer do' do
      let(:json) { { 'd' => 1, 's' => [] } }

      it 'returns the integer' do
        expect(decoded).to eq(1)
      end
    end

    context 'with a float' do
      let(:json) { { 'd' => 1.8, 's' => [] } }

      it 'returns the float' do
        expect(decoded).to eq(1.8)
      end
    end

    context 'with true' do
      let(:json) { { 'd' => true, 's' => [] } }

      it 'returns the boolean' do
        expect(decoded).to eq(true)
      end
    end

    context 'with false' do
      let(:json) { { 'd' => false, 's' => [] } }

      it 'returns the boolean' do
        expect(decoded).to eq(false)
      end
    end

    context 'with nil' do
      let(:json) { { 'd' => nil, 's' => [] } }

      it 'returns the nil object' do
        expect(decoded).to be_nil
      end
    end

    context 'with an array' do
      let(:json) { { 'a' => [1, 'e'], 's' => [] } }

      it 'returns the array' do
        expect(decoded).to eq([1, 'e'])
      end
    end

    context 'with a hash' do
      let(:json) { { 'a' => { 'key' => 'value' }, 's' => [] } }

      it 'returns the hash' do
        expect(decoded).to eq('key' => 'value')
      end
    end

    context 'with a simple object' do
      let(:json) do
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

      it 'returns a new instance of the object' do
        expect(decoded).to be_a(SerializeMe)
      end

      it 'returns an instance with the correct instance variables' do
        expect(decoded.instance_variable_get(:@initialized)).to \
          eq(true)
      end
    end

    context 'with an object with circular dependencies' do
      let(:json) do
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

      it 'returns the correct object type' do
        expect(decoded).to be_a(SerializeCircular::Parent)
      end

      it 'correctly instantes child objects' do
        expect(decoded.child).to be_a(SerializeCircular::Child)
      end
    end
  end
end
