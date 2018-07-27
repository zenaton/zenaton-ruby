# frozen_string_literal: true

require 'zenaton/services/properties'
require 'fixtures/serialize_me'

RSpec.describe Zenaton::Services::Properties do
  let(:properties) { described_class.new }

  describe '#blank_instance' do
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

  describe '#from' do
    let(:object) { SerializeMe.new }

    it 'returns a hash of the object instance variables' do
      expect(properties.from(object)).to eq(:@initialized => true)
    end
  end

  describe '#set' do
    let(:blank_object) { properties.blank_instance('SerializeMe') }
    let(:setup_object) { properties.set(blank_object, :@initialized => true) }

    it 'sets the given instance variables' do
      expect(setup_object.instance_variable_get(:@initialized)).to eq(true)
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
      expect { valid_object_with_superclass }.not_to raise_error ArgumentError
    end

    it 'sets the given instance variables on the object' do
      expect(valid_object.instance_variable_get(:@initialized)).to \
        eq(true)
    end
  end
end
