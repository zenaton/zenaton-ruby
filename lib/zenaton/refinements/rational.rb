# frozen_string_literal: true

defined?(::Rational) or require 'rational'

module Zenaton
  module Refinements
    refine Rational do
      def zenaton_properties
        {
          'n' => numerator,
          'd' => denominator
        }
      end
    end
  end
end
