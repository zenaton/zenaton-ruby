# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Rational do
      # Convert to a simple hash
      def to_zenaton
        {
          'n' => numerator,
          'd' => denominator
        }
      end
    end
  end
end

# Reimplements `json/add/rational`
class Rational
  # Parse from simple hash
  def self.from_zenaton(props)
    Rational(props['n'], props['d'])
  end
end
