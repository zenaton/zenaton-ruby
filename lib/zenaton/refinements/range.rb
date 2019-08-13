# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Range do
      def zenaton_properties
        {
          'a' => [first, last, exclude_end?]
        }
      end
    end
  end
end
