# frozen_string_literal: true
defined?(::BigDecimal) or require 'bigdecimal'

module Zenaton
  module Refinements
    refine BigDecimal do
      def zenaton_properties
        {
          'b' => _dump,
        }
      end
    end
  end
end
