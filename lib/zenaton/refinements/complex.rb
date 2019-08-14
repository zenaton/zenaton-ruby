# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Complex do
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
  def self.from_zenaton(props)
    Complex(props['r'], props['i'])
  end
end
