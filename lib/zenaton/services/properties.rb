# frozen_string_literal: true

module Zenaton
  module Services
    # Wrapper class to read instance variables from an object and
    # to create new objects with a given set of instance variables.
    class Properties
      # Returns an allocated instance of the given class name
      # @param class_name [String] the name of the class to allocate
      # @return [Object]
      def blank_instance(class_name)
        Object.const_get(class_name).allocate
      end

      # Returns a hash with the instance variables of a given object
      # @param object [Object] the object to be read
      # @return [Hash]
      def from(object)
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
    end
  end
end
