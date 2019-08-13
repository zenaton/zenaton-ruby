# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Range do
      def zenaton_props
        {
          'a' => [first, last, exclude_end?]
        }
      end
    end
  end
end
