# frozen_string_literal: true

require 'singleton'
require 'zenaton/refinements'

module Zenaton
  module Services
    # Wrapper class to read instance variables from an object and
    # to create new objects with a given set of instance variables.
    class Properties
      using Zenaton::Refinements
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
        object.to_zenaton
      end

      # Returns the given object with the properties as instance variables
      # @param object [Object] the object to write the variables to
      # @param properties [Hash] the properties to be written
      # @return [Object]
      def set(object, properties)
        klass = object.class
        return klass.from_zenaton(properties) if defined?(klass.from_zenaton)

        fallback_set(object, properties)
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

      def fallback_set(object, properties)
        properties.each do |ivar, value|
          object.instance_variable_set(ivar, value)
        end
        object
      end
    end
  end
end
