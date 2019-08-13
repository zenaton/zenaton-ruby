# frozen_string_literal: true
defined?(::Complex) or require 'complex'

module Zenaton
  module Refinements
    refine Complex do
      def zenaton_properties
        {
          'r' => real,
          'i' => imag 
        }
      end
    end
  end
end
