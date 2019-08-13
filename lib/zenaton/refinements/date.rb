# frozen_string_literal: true

require 'date'

module Zenaton
  # :nodoc
  module Refinements
    refine Date do
      def zenaton_props
        {
          'y' => year,
          'm' => month,
          'd' => day,
          'sg' => start
        }
      end
    end
  end
end
