# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Struct do
      def zenaton_properties
        {
          'v' => values
        }
      end
    end
  end
end
