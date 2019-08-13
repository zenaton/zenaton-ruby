# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Rational do
      def zenaton_props
        {
          'n' => numerator,
          'd' => denominator
        }
      end
    end
  end
end
