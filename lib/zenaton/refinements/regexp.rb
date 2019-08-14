# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Regexp do
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
  def self.from_zenaton(props)
    new(props['s'], props['o'])
  end
end
