# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Regexp do
      # Convert to a simple hash
      def to_zenaton
        {
          'o' => options,
          's' => source
        }
      end
    end
  end
end

# Reimplements `json/add/regexp`
class Regexp
  # Parse from simple hash
  def self.from_zenaton(props)
    new(props['s'], props['o'])
  end
end
