# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Regexp do
      def zenaton_props
        {
          'o' => options,
          's' => source
        }
      end
    end
  end
end
