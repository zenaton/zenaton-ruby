# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Time do
      # Convert to a simple hash
      def to_zenaton
        nanoseconds = [tv_usec * 1000]
        respond_to?(:tv_nsec) && nanoseconds << tv_nsec
        nanoseconds = nanoseconds.max
        {
          's' => tv_sec,
          'n' => nanoseconds
        }
      end
    end
  end
end

# Reimplements `json/add/time`
class Time
  # Parse from simple hash
  def self.from_zenaton(props)
    if (usec = props.delete('u')) # used to be tv_usec -> tv_nsec
      props['n'] = usec * 1000
    end
    if method_defined?(:tv_nsec)
      at(props['s'], Rational(props['n'], 1000))
    else
      at(props['s'], props['n'] / 1000)
    end
  end
end
