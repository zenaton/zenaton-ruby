# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Time do
      def zenaton_properties
        nanoseconds = [ tv_usec * 1000 ]
        respond_to?(:tv_nsec) and nanoseconds << tv_nsec
        nanoseconds = nanoseconds.max
        {
          's' => tv_sec,
          'n' => nanoseconds,
        }
      end
    end
  end
end
