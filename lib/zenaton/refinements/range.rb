# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Range do
      # Convert to a simple hash
      def to_zenaton
        {
          'a' => [first, last, exclude_end?]
        }
      end
    end
  end
end

# Reimplements `json/add/range`
class Range
  # Parse from simple hash
  def self.from_zenaton(props)
    new(*props['a'])
  end
end
