# frozen_string_literal: true

require 'singleton'
require 'bigdecimal'

module Zenaton
  module Services
    # Wrapper class to read instance variables from an object and
    # to create new objects with a given set of instance variables.
    class Properties
      # Handle (de)serializaton separately for these classes.
      SPECIAL_CASES = [
        ::Class,
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
        case object
        when Symbol
          from_symbol(object)
        when Struct
          from_struct(object)
        when OpenStruct
          from_open_struct(object)
        when Range
          from_range(object)
        when Regexp
          from_regexp(object)
        when DateTime
          from_date_time(object)
        when Date
          from_date(object)
        when Time
          from_time(object)
        when Rational
          from_rational(object)
        when Complex
          from_complex(object)
        when BigDecimal
          from_big_decimal(object)
        when Exception
          from_exception(object)
        when Class
          from_class(object)
        else
          JSON.parse(object.to_json).tap do |attributes|
            attributes.delete('json_class')
          end
        end
      end

      def set_complex_type(object, props)
        case object
        when Symbol
          set_symbol(object, props)
        when Struct
          set_struct(object, props)
        when OpenStruct
          set_open_struct(object, props)
        when Range
          set_range(object, props)
        when Regexp
          set_regexp(object, props)
        when DateTime
          set_date_time(object, props)
        when Date
          set_date(object, props)
        when Time
          set_time(object, props)
        when Rational
          set_rational(object, props)
        when Complex
          set_complex(object, props)
        when BigDecimal
          set_big_decimal(object, props)
        when Exception
          set_exception(object, props)
        when Class
          set_class(object, props)
        else
          props['json_class'] = object.class.name
          JSON(props.to_json)
        end
      end

      def special_case?(object)
        SPECIAL_CASES.include?(object.class) \
          || object.is_a?(Struct) \
          || object.is_a?(Exception)
      end

      # Symbol
      def from_symbol(symbol)
        { 's' => symbol.to_s }
      end

      def set_symbol(_object, props)
        props['s'].to_sym
      end

      # Class
      def from_class(klass)
        { 'n' => klass.name }
      end

      def set_class(_object, props)
        Object.const_get(props['n'])
      end

      # Struct
      def from_struct(struct)
        { 'v' => struct.values }
      end

      def set_struct(object, props)
        object.class.new(*props['v'])
      end

      # OpenStruct
      def from_open_struct(open_struct)
        klass = open_struct.class.name
        klass.to_s.empty? and raise JSON::JSONError, "Only named structs are supported!"
        {
          't' => open_struct.to_h.inject({}){|memo,(k,v)| memo[k.to_s] = v; memo},
        }
      end

      def set_open_struct(_object, props)
        OpenStruct.new(props['t'] || props[:t])
      end

      # Range
      def from_range(range)
        { 'a' => [range.first, range.last, range.exclude_end?] }
      end

      def set_range(_object, props)
        Range.new(*props['a'])
      end

      # Regexp
      def from_regexp(regexp)
        { 'o' => regexp.options, 's' => regexp.source }
      end

      def set_regexp(_object, props)
        Regexp.new(props['s'], props['o'])
      end

      # Rational
      def from_rational(rational)
        {
          'n' => rational.numerator,
          'd' => rational.denominator,
        }
      end

      def set_rational(_object, props)
        Rational(props['n'], props['d'])
      end

      # Complex
      def from_complex(complex)
        {
          'r' => complex.real,
          'i' => complex.imag,
        }
      end

      def set_complex(_object, props)
        Complex(props['r'], props['i'])
      end

      # BigDecimal
      def from_big_decimal(big_decimal)
        {
          'b' => big_decimal._dump,
        }
      end

      def set_big_decimal(_object, props)
        BigDecimal._load(props['b'])
      end

      # Exception
      def from_exception(exception)
        {
          'm' => exception.message,
          'b' => exception.backtrace,
        }
      end

      def set_exception(_object, props)
        result = Exception.new(props['m'])
        result.set_backtrace(props['b'])
        result
      end

      # Date
      def from_date(date)
        {
          'y' => date.year,
          'm' => date.month,
          'd' => date.day,
          'sg' => date.start
        }
      end

      def set_date(_object, props)
        Date.civil(*props.values_at('y', 'm', 'd', 'sg'))
      end

      # Time
      def from_time(time)
        nanoseconds = [time.tv_usec * 1000]
        time.respond_to?(:tv_nsec) and nanoseconds << time.tv_nsec
        nanoseconds = nanoseconds.max
        {
          's' => time.tv_sec,
          'n' => nanoseconds,
        }
      end

      def set_time(_object, props)
        if usec = props.delete('u') # used to be tv_usec -> tv_nsec
          props['n'] = usec * 1000
        end
        if Time.method_defined?(:tv_nsec)
          Time.at(props['s'], Rational(props['n'], 1000))
        else
          Time.at(props['s'], props['n'] / 1000)
        end
      end

      # DateTime
      def from_date_time(date_time)
        {
          'y' => date_time.year,
          'm' => date_time.month,
          'd' => date_time.day,
          'H' => date_time.hour,
          'M' => date_time.min,
          'S' => date_time.sec,
          'of' => date_time.offset.to_s,
          'sg' => date_time.start,
        }
      end

      def set_date_time(_object, props)
        args = props.values_at('y', 'm', 'd', 'H', 'M', 'S')
        of_a, of_b = props['of'].split('/')
        if of_b and of_b != '0'
          args << Rational(of_a.to_i, of_b.to_i)
        else
          args << of_a
        end
        args << props['sg']
        DateTime.civil(*args)
      end
    end
  end
end
