# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Struct do
      # Convert to a simple hash
      def to_zenaton
        class_name = self.class.name.to_s
        error_message = 'Only named structs are supported'
        raise ArgumentError, error_message if class_name.empty?
        {
          'v' => values
        }
      end
    end
  end
end

# Reimplements `json/add/struct`
class Struct
  # Parse from simple hash
  def self.from_zenaton(props)
    new(*props['v'])
  end
end
