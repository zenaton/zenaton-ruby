# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Struct do
      def zenaton_props
        {
          'v' => values
        }
      end
    end
  end
end
