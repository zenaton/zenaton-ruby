# frozen_string_literal: true

require 'zenaton/services/serializer'
require 'fixtures/serialize_me'
require 'fixtures/fake_active_model'

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

    context 'with a symbol' do
      let(:data) { :foobar }

      it 'represents the symbol as a data' do
        expect(parsed_json).to eq(
          'o' => '@zenaton#0',
          's' => [{ 'n' => 'Symbol', 'p' => { 's' => 'foobar' } }]
        )
      end
    end

    context 'with an integer' do
      let(:data) { 1 }

      it 'represents the integer as a data' do
        expect(parsed_json).to eq('d' => 1, 's' => [])
      end
    end

    context 'with a float' do
      let(:data) { 1.8 }

      it 'represents the float as a data' do
        expect(parsed_json).to eq('d' => 1.8, 's' => [])
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

    context 'with a Time' do
      let(:data) { Time.at(15) }

      it 'represents the time as an object' do
        expect(parsed_json).to \
          eq('o' => '@zenaton#0',
             's' => [{ 'n' => 'Time', 'p' => { 's' => 15, 'n' => 0 } }])
      end
    end

    context 'with a Date' do
      let(:data) { Date.new(2018, 8, 1) }
      let(:expected_serialization) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'n' => 'Date',
            'p' => { 'y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0 }
          }]
        }
      end

      it 'represents the date as a data' do
        expect(parsed_json).to eq(expected_serialization)
      end
    end

    context 'with a DateTime' do
      # rubocop:disable Style/DateTime
      let(:data) { DateTime.parse('2018-08-01T16:21:31+02:00') }

      let(:expected_serialization) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'n' => 'DateTime',
            'p' => {
              'y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0,
              'H' => 16, 'M' => 21, 'S' => 31, 'of' => '1/12'
            }
          }]
        }
      end

      it 'represents the time as a data' do
        expect(parsed_json).to eq(expected_serialization)
      end
      # rubocop:enable Style/DateTime
    end

    context 'with an array' do
      let(:data) { [1, 'e'] }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => [1, 'e']
          }]
        }
      end

      it 'represents the array as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with recursive arrays' do
      let(:array1) { [1, 2, 3] }
      let(:array2) { [4, 5, 6] }
      let(:data) { array1 }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => [1, 2, 3, '@zenaton#1']
          }, {
            'a' => [4, 5, 6, '@zenaton#0']
          }]
        }
      end

      before do
        array1 << array2
        array2 << array1
      end

      it 'represents the array as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with empty arrays' do
      let(:array1) { [] }
      let(:array2) { [] }
      let(:data) { array1 }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => ['@zenaton#1']
          }, {
            'a' => ['@zenaton#0']
          }]
        }
      end

      before do
        array1 << array2
        array2 << array1
      end

      it 'represents the two empty arrays as distinct objects' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with a hash' do
      let(:data) { { 'key' => 'value' } }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => {
              'key' => 'value'
            }
          }]
        }
      end

      it 'represents the hash as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with circular hashes' do
      let(:hash1) { { 'first' => 1 } }
      let(:hash2) { { 'second' => 2 } }
      let(:data) { hash1 }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => {
              'first' => 1,
              'child' => '@zenaton#1'
            }
          }, {
            'a' => {
              'second' => 2,
              'parent' => '@zenaton#0'
            }
          }]
        }
      end

      before do
        hash1[:child] = hash2
        hash2[:parent] = hash1
      end

      it 'represents the hash as an object' do
        expect(parsed_json).to eq(expected_representation)
      end
    end

    context 'with empty circular hashes' do
      let(:hash1) { {} }
      let(:hash2) { {} }
      let(:data) { hash1 }
      let(:expected_representation) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => { 'foo' => '@zenaton#1' }
          }, {
            'a' => { 'foo' => '@zenaton#0' }
          }]
        }
      end

      before do
        hash1[:foo] = hash2
        hash2[:foo] = hash1
      end

      it 'represents the two empty hashes as distinct objects' do
        expect(parsed_json).to eq(expected_representation)
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

    context 'with an object that overrides ==' do
      let(:data) { FakeActiveModel.new(name: 'Bob') }

      it 'does not raise error' do
        expect { parsed_json }.not_to \
          raise_error NoMethodError
      end
    end
  end

  describe '#decode' do
    let(:decoded) { serializer.decode(json) }

    context 'with a string do' do
      let(:json) { { 'd' => 'e', 's' => [] }.to_json }

      it 'returns the string' do
        expect(decoded).to eq('e')
      end
    end

    context 'with a symbol do' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{ 'n' => 'Symbol', 'p' => { 's' => 'foobar' } }]
        }.to_json
      end

      it 'returns the symbol' do
        expect(decoded).to eq(:foobar)
      end
    end

    context 'with an integer do' do
      let(:json) { { 'd' => 1, 's' => [] }.to_json }

      it 'returns the integer' do
        expect(decoded).to eq(1)
      end
    end

    context 'with a float' do
      let(:json) { { 'd' => 1.8, 's' => [] }.to_json }

      it 'returns the float' do
        expect(decoded).to eq(1.8)
      end
    end

    context 'with true' do
      let(:json) { { 'd' => true, 's' => [] }.to_json }

      it 'returns the boolean' do
        expect(decoded).to eq(true)
      end
    end

    context 'with false' do
      let(:json) { { 'd' => false, 's' => [] }.to_json }

      it 'returns the boolean' do
        expect(decoded).to eq(false)
      end
    end

    context 'with nil' do
      let(:json) { { 'd' => nil, 's' => [] }.to_json }

      it 'returns the nil object' do
        expect(decoded).to be_nil
      end
    end

    context 'with a Time' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{ 'n' => 'Time', 'p' => { 's' => 15, 'n' => 0 } }]
        }.to_json
      end

      it 'returns the correct time' do
        expect(decoded).to eq(Time.at(15))
      end
    end

    context 'with a Date' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'n' => 'Date',
            'p' => { 'y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0 }
          }]
        }.to_json
      end
      let(:date) { Date.new(2018, 8, 1) }

      it 'returns the correct date' do
        expect(decoded).to eq(date)
      end
    end

    context 'with a DateTime' do
      # rubocop:disable Style/DateTime
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'n' => 'DateTime',
            'p' => {
              'y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0,
              'H' => 16, 'M' => 21, 'S' => 31, 'of' => '1/12'
            }
          }]
        }.to_json
      end
      let(:date_time) { DateTime.parse('2018-08-01T16:21:31+02:00') }

      it 'returns the correct datetime' do
        expect(decoded).to eq(date_time)
      end
      # rubocop:enable Style/DateTime
    end

    context 'with an old array format' do
      let(:json) { { 'a' => [1, 'e'], 's' => [] }.to_json }

      it 'returns the array' do
        expect(decoded).to eq([1, 'e'])
      end
    end

    context 'with an old hash format' do
      let(:json) { { 'a' => { 'key' => 'value' }, 's' => [] }.to_json }

      it 'returns the hash' do
        expect(decoded).to eq('key' => 'value')
      end
    end

    context 'with nested old format' do
      let(:json) do
        {
          'a' => expected_structure,
          's' => []
        }.to_json
      end
      let(:expected_structure) do
        {
          'array' => [{ 'key' => 'value' }],
          'hash' => {
            'subarray' => [1, 2, 3]
          }
        }
      end

      it 'parses the nested arrays and hashes successfully' do
        expect(decoded).to eq(expected_structure)
      end
    end

    context 'with a new array format' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => [1, '@zenaton#1']
          }, {
            'a' => [2, '@zenaton#0']
          }]
        }.to_json
      end

      it 'returns an array' do
        expect(decoded).to be_an(Array)
      end

      it 'has correct cyclic structure' do
        expect(decoded[-1][-1]).to eq(decoded)
      end
    end

    context 'with a empty circular arrays' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => ['@zenaton#1']
          }, {
            'a' => ['@zenaton#0']
          }]
        }.to_json
      end

      it 'returns an array' do
        expect(decoded).to be_a(Array)
      end

      it 'has correct circular structure' do
        expect(decoded[-1][-1]).to be(decoded)
      end

      it 'distinguishes between children' do
        expect(decoded[-1]).not_to be(decoded)
      end
    end

    context 'with a new hash format' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => {
              'first' => 1,
              'child' => '@zenaton#1'
            }
          }, {
            'a' => {
              'second' => 2,
              'parent' => '@zenaton#0'
            }
          }]
        }.to_json
      end

      it 'returns a hash' do
        expect(decoded).to be_a(Hash)
      end

      it 'has correct circular structure' do
        expect(decoded['child']['parent']).to eq(decoded)
      end
    end

    context 'with empty circular hashes' do
      let(:json) do
        {
          'o' => '@zenaton#0',
          's' => [{
            'a' => {
              'foo' => '@zenaton#1'
            }
          }, {
            'a' => {
              'foo' => '@zenaton#0'
            }
          }]
        }.to_json
      end

      it 'returns a hash' do
        expect(decoded).to be_a(Hash)
      end

      it 'has correct circular structure' do
        expect(decoded['foo']['foo']).to be(decoded)
      end

      it 'distinguishes between the children' do
        expect(decoded['foo']).not_to be(decoded)
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
        }.to_json
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
        }.to_json
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
