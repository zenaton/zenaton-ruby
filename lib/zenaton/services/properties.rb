# frozen_string_literal: true

require 'singleton'

module Zenaton
  module Services
    # Wrapper class to read instance variables from an object and
    # to create new objects with a given set of instance variables.
    class Properties
      # Handle (de)serializaton separately for these classes.
      SPECIAL_CASES = [
        Time,
        Date,
        DateTime,
        Rational,
        Complex
      ].freeze

      # Returns an allocated instance of the given class name
      # @param class_name [String] the name of the class to allocate
      # @return [Object]
      def blank_instance(class_name)
        klass = Object.const_get(class_name)
        if klass < Singleton
          klass.instance
        elsif [Rational, Complex].include?(klass)
          Kernel.send(klass.to_s, 1, 1)
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
        case object.class.name
        when 'Time'
          from_time(object)
        when 'Date'
          from_date(object)
        when 'DateTime'
          from_date_time(object)
        when 'Rational'
          from_rational(object)
        when 'Complex'
          from_complex(object)
        end
      end

      def from_time(object)
        nanoseconds = [object.tv_usec * 1_000]
        object.respond_to?(:tv_nsec) && nanoseconds << object.tv_nsec
        { 's' => object.tv_sec, 'n' => nanoseconds.max }
      end

      def from_date(object)
        { 'y' => object.year, 'm' => object.month,
          'd' => object.day, 'sg' => object.start }
      end

      def from_date_time(object)
        {
          'y' => object.year, 'm' => object.month, 'd' => object.day,
          'H' => object.hour, 'M' => object.minute, 'S' => object.sec,
          'of' => object.offset.to_s, 'sg' => object.start
        }
      end

      def from_rational(object)
        { 'n' => object.numerator, 'd' => object.denominator }
      end

      def from_complex(object)
        { 'r' => object.real, 'i' => object.imaginary }
      end

      def set_complex_type(object, props)
        case object.class.name
        when 'Time'
          return_time(object, props)
        when 'Date'
          return_date(props)
        when 'DateTime'
          return_date_time(props)
        when 'Rational'
          return_rational(props)
        when 'Complex'
          return_complex(props)
        end
      end

      def return_time(object, props)
        if object.respond_to?(:tv_usec)
          Time.at(props['s'], Rational(props['n'], 1000))
        else
          Time.at(props['s'], props['n'] / 1000)
        end
      end

      def return_date(props)
        Date.civil(*props.values_at('y', 'm', 'd', 'sg'))
      end

      def return_date_time(props)
        args = props.values_at('y', 'm', 'd', 'H', 'M', 'S')
        of_a, of_b = props['of'].split('/')
        args << if of_b && of_b != 0
                  Rational(of_a.to_i, of_b.to_i)
                else
                  of_a
                end
        args << props['sg']
        DateTime.civil(*args) # rubocop:disable Style/DateTime
      end

      def return_rational(props)
        Rational(props['n'], props['d'])
      end

      def return_complex(props)
        Complex(props['r'], props['i'])
      end

      def special_case?(object)
        SPECIAL_CASES.include?(object.class)
      end
    end
  end
end
