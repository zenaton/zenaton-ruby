# frozen_string_literal: true

# rubocop:disable Style/AndOr
defined?(::BigDecimal) or require 'bigdecimal'
# rubocop:enable Style/AndOr

module Zenaton
  # :nodoc
  module Refinements
    refine BigDecimal do
      def zenaton_props
        {
          'b' => _dump
        }
      end
    end
  end
end
