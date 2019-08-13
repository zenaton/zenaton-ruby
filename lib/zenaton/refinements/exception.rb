# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Exception do
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
  def self.from_zenaton(props)
    result = new(props['m'])
    result.set_backtrace props['b']
    result
  end
end
