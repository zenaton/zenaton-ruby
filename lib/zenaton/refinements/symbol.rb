# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Symbol do
      def zenaton_props
        {
          's' => to_s
        }
      end
    end
  end
end
