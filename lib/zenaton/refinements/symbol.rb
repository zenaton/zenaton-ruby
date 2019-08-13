# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Symbol do
      def zenaton_properties
        {
          's' => to_s
        }
      end
    end
  end
end
