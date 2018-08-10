# frozen_string_literal: true

require 'singleton'
require 'json/add/core'
require 'json/add/rational'
require 'json/add/complex'
require 'json/add/bigdecimal'
require 'json/add/ostruct'

module Zenaton
  module Services
    # Wrapper class to read instance variables from an object and
    # to create new objects with a given set of instance variables.
    class Properties
      # Handle (de)serializaton separately for these classes.
      SPECIAL_CASES = [
        ::Complex,
        ::Date,
        ::DateTime,
        ::Range,
        ::Rational,
        ::Regexp,
        ::Symbol,
        ::Time,
        defined?(::OpenStruct) ? ::OpenStruct : nil,
        defined?(::BigDecimal) ? ::BigDecimal : nil
      ].compact.freeze

      # Handle blank object instantiation differently for these classes
      NUMERIC_INITIALIATION = [
        ::Rational,
        ::Complex,
        defined?(::BigDecimal) ? ::BigDecimal : nil
      ].compact.freeze

      # Returns an allocated instance of the given class name
      # @param class_name [String] the name of the class to allocate
      # @return [Object]
      def blank_instance(class_name)
        klass = Object.const_get(class_name)
        if klass < ::Singleton
          klass.instance
        elsif NUMERIC_INITIALIATION.include?(klass)
          Kernel.send(klass.to_s, 1, 1)
        elsif klass == Symbol
          :place_holder
        else
          klass.allocate
        end
      end

      # Returns a hash with the instance variables of a given object
      # @param object [Object] the object to be read
      # @return [Hash]
      def from(object)
        return from_complex_type(object) if special_case?(object)
        object.instance_variables.map do |ivar|
          value = object.instance_variable_get(ivar)
          [ivar, value]
        end.to_h
      end

      # Returns the given object with the properties as instance variables
      # @param object [Object] the object to write the variables to
      # @param properties [Hash] the properties to be written
      # @return [Object]
      def set(object, properties)
        return set_complex_type(object, properties) if special_case?(object)
        properties.each do |ivar, value|
          object.instance_variable_set(ivar, value)
        end
        object
      end

      # Given a class name and a set of properties, return a new instance of the
      # class with the given properties as instance variables
      # @param class_name [String] name of the class to instantiate
      # @param properties [Hash] the properties to be written
      # @param super_class [Class] the optional class the object should inherit
      # @return [Object]
      def object_from(class_name, properties, super_class = nil)
        blank_instance(class_name).tap do |object|
          check_class(object, super_class)
          set(object, properties)
        end
      end

      private

      def check_class(object, super_class)
        msg = "Error - #{object.class} should be an instance of #{super_class}"
        raise ArgumentError, msg unless valid_object(object, super_class)
      end

      def valid_object(object, super_class)
        super_class.nil? || object.is_a?(super_class)
      end

      def from_complex_type(object)
        JSON.parse(object.to_json).tap do |attributes|
          attributes.delete('json_class')
        end
      end

      def set_complex_type(object, props)
        props['json_class'] = object.class.name
        JSON(props.to_json)
      end

      def special_case?(object)
        SPECIAL_CASES.include?(object.class) \
          || object.is_a?(Struct) \
          || object.is_a?(Exception)
      end
    end
  end
end
