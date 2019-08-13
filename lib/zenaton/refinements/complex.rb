# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Complex do
      def zenaton_props
        {
          'r' => real,
          'i' => imag
        }
      end
    end
  end
end
