# frozen_string_literal: true

require 'date'

module Zenaton
  module Refinements
    refine Date do
      def zenaton_properties
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
