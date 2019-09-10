# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Symbol do
      # Convert to a simple hash
      def to_zenaton
        {
          's' => to_s
        }
      end
    end
  end
end

# Reimplements `json/add/symbol`
class Symbol
  # Parse from simple hash
  def self.from_zenaton(props)
    props['s'].to_sym
  end
end
