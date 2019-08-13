# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Exception do
      def zenaton_props
        {
          'm' => message,
          'b' => backtrace
        }
      end
    end
  end
end
