# frozen_string_literal: true

require 'ostruct'

module Zenaton
  # :nodoc
  module Refinements
    refine OpenStruct do
      def zenaton_props
        {
          't' => table
        }
      end
    end
  end
end
