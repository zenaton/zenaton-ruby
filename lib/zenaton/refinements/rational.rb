# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Rational do
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
  def self.from_zenaton(props)
    Rational(props['n'], props['d'])
  end
end
