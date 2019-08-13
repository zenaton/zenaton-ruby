# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Exception do
      def zenaton_properties
        {
          'm' => message,
          'b' => backtrace
        }
      end
    end
  end
end
