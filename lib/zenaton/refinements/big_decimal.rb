# frozen_string_literal: true

# rubocop:disable Style/AndOr
defined?(::BigDecimal) or require 'bigdecimal'
# rubocop:enable Style/AndOr

module Zenaton
  # :nodoc
  module Refinements
    refine BigDecimal do
      # Convert to a simple hash
      def to_zenaton
        {
          'b' => _dump
        }
      end
    end
  end
end

# Reimplements `json/add/bigdecimal`
class BigDecimal
  # Parse from simple hash
  def self.from_zenaton(props)
    BigDecimal._load props['b']
  end
end
