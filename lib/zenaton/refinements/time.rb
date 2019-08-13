# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Time do
      def zenaton_props
        nanoseconds = [tv_usec * 1000]
        respond_to?(:tv_nsec) && nanoseconds << tv_nsec
        nanoseconds = nanoseconds.max
        {
          's' => tv_sec,
          'n' => nanoseconds
        }
      end
    end
  end
end
