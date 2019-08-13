# frozen_string_literal: true

require 'date'

module Zenaton
  module Refinements
    refine DateTime do
      def zenaton_properties
        {
          'y' => year,
          'm' => month,
          'd' => day,
          'H' => hour,
          'M' => min,
          'S' => sec,
          'of' => offset.to_s,
          'sg' => start
        }
      end
    end
  end
end
