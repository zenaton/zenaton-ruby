# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Complex do
      # Convert to a simple hash
      def to_zenaton
        {
          'r' => real,
          'i' => imag
        }
      end
    end
  end
end

# Reimplements `json/add/complex`
class Complex
  # Parse from simple hash
  def self.from_zenaton(props)
    Complex(props['r'], props['i'])
  end
end
