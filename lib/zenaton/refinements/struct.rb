# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Struct do
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
  def self.from_zenaton(props)
    new(*props['v'])
  end
end
