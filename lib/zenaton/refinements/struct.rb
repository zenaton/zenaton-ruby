# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Struct do
      def to_zenaton
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
