# frozen_string_literal: true

module Zenaton
  module Refinements
    refine Exception do
      # Convert to a simple hash
      def to_zenaton
        {
          'm' => message,
          'b' => backtrace
        }
      end
    end
  end
end

# Reimplements `json/add/exception`
class Exception
  # Parse from simple hash
  def self.from_zenaton(props)
    result = new(props['m'])
    result.set_backtrace props['b']
    result
  end
end
