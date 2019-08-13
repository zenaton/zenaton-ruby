# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Object do
      def zenaton_props
        instance_variables.map do |ivar|
          value = instance_variable_get(ivar)
          [ivar, value]
        end.to_h
      end
    end
  end
end
