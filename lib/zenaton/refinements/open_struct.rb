# frozen_string_literal: true

require 'ostruct'

module Zenaton
  module Refinements
    refine OpenStruct do
      # Convert to a simple hash
      def to_zenaton
        class_name = self.class.name.to_s
        error_message = 'Only named structs are supported'
        raise ArgumentError, error_message if class_name.empty?
        {
          't' => table
        }
      end
    end
  end
end

# Reimplements `json/add/ostruct`
class OpenStruct
  # Parse from simple hash
  def self.from_zenaton(props)
    new(props['t'] || props[:t])
  end
end
