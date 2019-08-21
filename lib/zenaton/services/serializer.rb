# frozen_string_literal: true

require 'json'
require 'zenaton/services/properties'

module Zenaton
  module Services
    # Encoding and decoding ruby objects into Zenaton's json format
    class Serializer
      # this string prefixs ids that are used to identify objects
      ID_PREFIX = '@zenaton#'

      KEY_OBJECT = 'o' # JSON key for objects
      KEY_OBJECT_NAME = 'n' # JSON key for class name
      KEY_OBJECT_PROPERTIES = 'p' # JSON key for object ivars
      KEY_ARRAY = 'a' # JSON key for array and hashes
      KEY_DATA = 'd' # JSON key for json compatibles types
      KEY_STORE = 's' # JSON key for deserialized complex object

      def initialize
        @properties = Properties.new
      end

      # rubocop:disable Metrics/MethodLength

      # Encodes a given ruby object to Zenaton's json format
      def encode(data)
        @encoded = []
        @decoded = []
        value = {}
        raise ArgumentError, 'Procs cannot be serialized' if data.is_a?(Proc)
        if basic_type?(data)
          value[KEY_DATA] = data
        else
          value[KEY_OBJECT] = encode_to_store(data)
        end
        value[KEY_STORE] = @encoded
        value.to_json
      end

      # Decodes Zenaton's format in a valid Ruby object
      def decode(json_string)
        parsed_json = JSON.parse(json_string)
        @decoded = []
        @encoded = parsed_json.delete(KEY_STORE)
        case parsed_json.keys.first
        when KEY_DATA
          return parsed_json[KEY_DATA]
        when KEY_ARRAY
          return decode_enumerable(parsed_json[KEY_ARRAY])
        when KEY_OBJECT
          id = parsed_json[KEY_OBJECT][ID_PREFIX.length..-1].to_i
          return decode_from_store(id, @encoded[id])
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def basic_type?(data)
        data.is_a?(String) \
          || data.is_a?(Integer) \
          || data.is_a?(Float) \
          || data.is_a?(TrueClass) \
          || data.is_a?(FalseClass) \
          || data.nil?
      end

      def encode_value(value)
        raise ArgumentError, 'Procs cannot be serialized' if value.is_a?(Proc)
        if basic_type?(value)
          value
        else
          encode_to_store(value)
        end
      end

      def encode_to_store(object)
        id = @decoded.index { |decoded| decoded.object_id == object.object_id }
        return store_id(id) if id
        store_and_encode(object)
      end

      def store_and_encode(object)
        id = @decoded.length
        @decoded[id] = object
        @encoded[id] = encoded_object_by_type(object)
        store_id(id)
      end

      def store_id(id)
        "#{ID_PREFIX}#{id}"
      end

      def encoded_object_by_type(object)
        case object
        when Array
          encode_array(object)
        when Hash
          encode_hash(object)
        else
          encode_object(object)
        end
      end

      def encode_object(object)
        {
          KEY_OBJECT_NAME => object.class.name,
          KEY_OBJECT_PROPERTIES => encode_legacy_hash(@properties.from(object))
        }
      end

      def encode_array(array)
        {
          KEY_ARRAY => array.map(&method(:encode_value))
        }
      end

      def encode_hash(hash)
        {
          KEY_ARRAY => transform_values(hash, &method(:encode_value))
        }
      end

      def encode_legacy_hash(hash)
        transform_values(hash, &method(:encode_value))
      end

      def store_id?(string)
        string.is_a?(String) \
          && string.start_with?(ID_PREFIX) \
          && string[ID_PREFIX.length..-1].to_i <= @encoded.length
      end

      # rubocop:disable Metrics/MethodLength
      def decode_element(value)
        if store_id?(value)
          id = value[ID_PREFIX.length..-1].to_i
          encoded = @encoded[id]
          decode_from_store(id, encoded)
        elsif value.is_a?(Array)
          decode_legacy_array(value)
        elsif value.is_a?(Hash)
          decode_legacy_hash(value)
        else
          value
        end
      end
      # rubocop:enable Metrics/MethodLength

      def decode_enumerable(enumerable)
        return decode_legacy_array(enumerable) if enumerable.is_a?(Array)
        return decode_legacy_hash(enumerable) if enumerable.is_a?(Hash)
        raise ArgumentError, 'Unknown type'
      end

      def decode_legacy_array(array)
        array.map(&method(:decode_element))
      end

      def decode_legacy_hash(hash)
        transform_values(hash, &method(:decode_element))
      end

      def decode_array(id, array)
        @decoded[id] = object = []
        object.concat(array.map(&method(:decode_element)))
      end

      def decode_hash(id, hash)
        @decoded[id] = {}
        hash.each do |key, value|
          @decoded[id][key] = decode_element(value)
        end
        @decoded[id]
      end

      def decode_from_store(id, encoded)
        decoded = @decoded[id]
        return decoded if decoded
        case encoded[KEY_ARRAY]
        when Array
          decode_array(id, encoded[KEY_ARRAY])
        when Hash
          decode_hash(id, encoded[KEY_ARRAY])
        else
          decode_object(id, encoded)
        end
      end

      def decoded_object_by_type(id, encoded)
        enumerable = encoded[KEY_ARRAY]
        case enumerable
        when Array
          decode_array(id, enumerable)
        when Hash
          decode_hash(id, enumerable)
        else
          decode_object(id, encoded)
        end
      end

      def decode_object(id, encoded_object)
        object = @properties.blank_instance(encoded_object[KEY_OBJECT_NAME])
        @decoded[id] = object
        properties = decode_legacy_hash(encoded_object[KEY_OBJECT_PROPERTIES])
        @properties.set(object, properties)
      end

      def transform_values(hash)
        hash.each_with_object({}) do |(k, v), acc|
          acc[k] = yield(v)
        end
      end
    end
  end
end
