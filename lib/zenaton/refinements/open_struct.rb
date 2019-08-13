# frozen_string_literal: true

require 'ostruct'

module Zenaton
  module Refinements
    refine OpenStruct do
      def zenaton_properties
        {
          't' => table
        }
      end
    end
  end
end
