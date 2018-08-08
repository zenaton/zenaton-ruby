# frozen_string_literal: true

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
        if data.is_a?(Array)
          value[KEY_OBJECT] = encode_array(data)
        elsif data.is_a?(Hash)
          value[KEY_OBJECT] = encode_hash(data)
        elsif basic_type?(data)
          value[KEY_DATA] = data
        else
          value[KEY_OBJECT] = encode_object(data)
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
          return decode_object(id, @encoded[id])
        end
      end
      # rubocop:enable Metrics/MethodLength

      private

      def array_type?(data)
        data.is_a?(Array) || data.is_a?(Hash)
      end

      def basic_type?(data)
        data.is_a?(String) \
          || data.is_a?(Integer) \
          || data.is_a?(Float) \
          || data == true \
          || data == false \
          || data.nil?
      end

      def encode_array(array)
        id = @decoded.index(array)
        unless id
          id = @decoded.length
          @decoded[id] = array
          @encoded[id] = {
            KEY_ARRAY => array.map(&method(:encode_value))
          }
        end
        "#{ID_PREFIX}#{id}"
      end

      def encode_hash(hash)
        id = @decoded.index(hash)
        unless id
          id = @decoded.length
          @decoded[id] = hash
          @encoded[id] = {
            KEY_ARRAY => transform_values(hash, &method(:encode_value))
          }
        end
        "#{ID_PREFIX}#{id}"
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
            KEY_OBJECT_PROPERTIES => transform_values(@properties.from(object), &method(:encode_value))
          }
        end
        "#{ID_PREFIX}#{id}"
      end

      def object_id?(string)
        string.is_a?(String) \
          && string.start_with?(ID_PREFIX) \
          && string[ID_PREFIX.length..-1].to_i <= @encoded.length
      end

      def decode_enumerable(enumerable)
        return decode_array(enumerable) if enumerable.is_a?(Array)
        return decode_hash(enumerable) if enumerable.is_a?(Hash)
        raise ArgumentError, 'Unknown type'
      end

      def decode_array(array)
        array.map { |elem| decode_element(elem) }
      end

      def decode_hash(hash)
        transform_values(hash) { |value| decode_element(value) }
      end

      # rubocop:disable Metrics/MethodLength
      def decode_element(value)
        if object_id?(value)
          id = value[ID_PREFIX.length..-1].to_i
          encoded = @encoded[id]
          decode_object(id, encoded) if encoded.is_a?(Hash)
        elsif value.is_a?(Array)
          decode_array(value)
        elsif value.is_a?(Hash)
          decode_hash(value)
        else
          value
        end
      end
      # rubocop:enable Metrics/MethodLength

      def decode_object(id, encoded_object)
        decoded = @decoded[id]
        return decoded if decoded
        object = @properties.blank_instance(encoded_object[KEY_OBJECT_NAME])
        @decoded[id] = object
        properties = decode_hash(encoded_object[KEY_OBJECT_PROPERTIES])
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
