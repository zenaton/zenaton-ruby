# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Regexp do
      def zenaton_properties
        {
          'o' => options,
          's' => source
        }
      end
    end
  end
end
