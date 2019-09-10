# frozen_string_literal: true

require 'date'

module Zenaton
  module Refinements
    refine DateTime do
      # Convert to a simple hash
      def to_zenaton
        {
          'y' => year,
          'm' => month,
          'd' => day,
          'H' => hour,
          'M' => min,
          'S' => sec,
          'of' => offset.to_s,
          'sg' => start
        }
      end
    end
  end
end

# Reimplements `json/add/date_time`
class DateTime
  # Parse from simple hash
  def self.from_zenaton(props)
    args = props.values_at('y', 'm', 'd', 'H', 'M', 'S')
    of_a, of_b = props['of'].split('/')
    # rubocop:disable Style/ConditionalAssignment
    if of_b && of_b != '0'
      args << Rational(of_a.to_i, of_b.to_i)
    else
      args << of_a
    end
    # rubocop:enable Style/ConditionalAssignment
    args << props['sg']
    civil(*args)
  end
end
