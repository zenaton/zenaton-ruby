# frozen_string_literal: true

require 'zenaton/services/properties'

module Zenaton
  module Services
    class Serializer
      # this string prefixs ids that are used to identify objects
      ID_PREFIX = '@zenaton#'

      KEY_OBJECT = 'o'
      KEY_OBJECT_NAME = 'n'
      KEY_OBJECT_PROPERTIES = 'p'
      KEY_ARRAY = 'a'
      KEY_DATA = 'd'
      KEY_STORE = 's'

      def initialize
        @properties = Properties.new
      end

      def encode(data)
        @encoded = []
        @decoded = []
        value = {}
        raise ArgumentError, 'Procs cannot be serialized' if data.is_a?(Proc)
        if data.is_a?(Array)
          value[KEY_ARRAY] = encode_array(data)
        elsif data.is_a?(Hash)
          value[KEY_ARRAY] = encode_hash(data)
        elsif basic_type?(data)
          value[KEY_DATA] = data
        else
          value[KEY_OBJECT] = encode_object(data)
        end
        value[KEY_STORE] = @encoded
        value.to_json
      end

      private

      def array_type?(data)
        data.is_a?(Array) || data.is_a?(Hash)
      end

      def basic_type?(data)
        data.is_a?(String) \
          || data.is_a?(Numeric) \
          || data == true \
          || data == false \
          || data.nil?
      end

      def encode_array(array)
        array.map { |elem| encode_value(elem) }
      end

      def encode_hash(hash)
        hash.transform_values { |value| encode_value(value) }
      end

      def encode_value(value)
        raise ArgumentError, 'Procs cannot be serialized' if value.is_a?(Proc)
        if value.is_a?(Array)
          encode_array(value)
        elsif value.is_a?(Hash)
          encode_hash(value)
        elsif basic_type?(value)
          value
        else
          encode_object(value)
        end
      end

      def encode_object(object)
        id = @decoded.index(object)
        unless id
          id = @decoded.length
          @decoded[id] = object
          @encoded[id] = {
            KEY_OBJECT_NAME => object.class.name,
            KEY_OBJECT_PROPERTIES => encode_hash(@properties.from(object))
          }
        end
        "#{ID_PREFIX}#{id}"
      end
    end
  end
end
