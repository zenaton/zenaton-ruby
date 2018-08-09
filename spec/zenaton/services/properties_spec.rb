# frozen_string_literal: true

require 'zenaton/services/properties'
require 'fixtures/serialize_me'

RSpec.describe Zenaton::Services::Properties do
  let(:properties) { described_class.new }

  describe '#blank_instance' do
    context 'with a regular class' do
      let(:instance) do
        properties.blank_instance('SerializeMe')
      end

      it 'creates a new instance of the provided class' do
        expect(instance).to be_a(SerializeMe)
      end

      it 'does not call initialize when instantiating' do
        expect(instance).not_to be_initialized
      end
    end

    context 'with a singleton class' do
      let(:instance) do
        properties.blank_instance('SerializeSingleton')
      end

      it 'fetches the instance of the provided class' do
        expect(instance).to be_a(SerializeSingleton)
      end

      it 'does not call initialize when instantiating' do
        expect(instance).not_to be_initialized
      end
    end
  end

  describe '#from' do
    let(:result) { properties.from(object) }

    context 'with time objects' do
      let(:object) { Time.at(15) }

      it 'returns the number of seconds and nanoseconds since epoch' do
        expect(result).to eq('s' => 15, 'n' => 0)
      end
    end

    context 'with date objects' do
      let(:object) { Date.new(2018, 8, 1) }

      it 'returns the year, month, day and day of calendar reform' do
        expect(result).to eq('y' => 2018, 'm' => 8, 'd' => 1, 'sg' => 2299161.0)
      end
    end

    context 'with DateTime objects' do
      # rubocop:disable Style/DateTime
      let(:object) { DateTime.parse('2018-08-01T08:21:31+02:00') }

      it 'returns the year, month, day and day of calendar reform' do
        expect(result).to \
          eq('y' => 2018, 'm' => 8, 'd' => 1, 'H' => 8, 'M' => 21,
             'S' => 31, 'of' => '1/12', 'sg' => 2299161.0)
      end
      # rubocop:enable Style/DateTime
    end

    context 'with rational numbers' do
      let(:object) { 2 / 3r }

      it 'returns the numerator and denominator' do
        expect(result).to eq('n' => 2, 'd' => 3)
      end
    end

    context 'with other objects' do
      let(:object) { SerializeMe.new }

      it 'returns a hash of the object instance variables' do
        expect(result).to eq(:@initialized => true)
      end
    end
  end

  describe '#set' do
    let(:blank_object) { properties.blank_instance(object_name) }
    let(:setup_object) { properties.set(blank_object, props) }

    context 'with time objects' do
      let(:object_name) { 'Time' }
      let(:props) { { 's' => 15, 'n' => 0 } }
      let(:expected_time) { Time.at(15) }

      it 'sets the props correctly' do
        expect(setup_object).to eq(expected_time)
      end
    end

    context 'with date objects' do
      let(:object_name) { 'Date' }
      let(:props) { { 'y' => 2018, 'm' => 12, 'd' => 1, 'sg' => 2299161.0 } }
      let(:expected_date) { Date.new(2018, 12, 1) }

      it 'sets the props correctly' do
        expect(setup_object).to eq(expected_date)
      end
    end

    context 'with date objects' do
      # rubocop:disable Style/DateTime
      let(:object_name) { 'DateTime' }
      let(:props) do
        { 'y' => 2018, 'm' => 8, 'd' => 1,
          'H' => 8, 'M' => 21, 'S' => 31,
          'of' => '1/12', 'sg' => 2299161.0 }
      end
      let(:expected_date_time) { DateTime.parse('2018-08-01T08:21:31+02:00') }

      it 'sets the props correctly' do
        expect(setup_object).to eq(expected_date_time)
      end
      # rubocop:enable Style/DateTime
    end

    context 'with rational numbers' do
      let(:object_name) { 'Rational' }
      let(:props) { { 'n' => 2, 'd' => 3 } }

      it 'sets the props correctly' do
        expect(setup_object).to eq(2 / 3r)
      end
    end

    context 'with other objects' do
      let(:object_name) { 'SerializeMe' }
      let(:props) { { :@initialized => true } }

      it 'sets the given instance variables' do
        expect(setup_object.instance_variable_get(:@initialized)).to eq(true)
      end
    end
  end

  describe '#object_from' do
    let(:invalid_object) do
      properties.object_from(
        'SerializeMe',
        { :@initialized => true },
        Array
      )
    end

    let(:valid_object) do
      properties.object_from(
        'SerializeMe',
        :@initialized => true
      )
    end

    let(:valid_object_with_superclass) do
      properties.object_from(
        'SerializeMe',
        { :@initialized => true },
        SerializeMe
      )
    end

    it 'returns an instance of the given class' do
      expect(valid_object).to be_a(SerializeMe)
    end

    it 'raises if object is not an instance of super_class' do
      expect { invalid_object }.to raise_error ArgumentError
    end

    it 'does not raise if object is an instance of superclass' do
      expect { valid_object_with_superclass }.not_to raise_error
    end

    it 'sets the given instance variables on the object' do
      expect(valid_object.instance_variable_get(:@initialized)).to \
        eq(true)
    end
  end
end
