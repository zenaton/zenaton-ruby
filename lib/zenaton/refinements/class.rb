# frozen_string_literal: true

module Zenaton
  # :nodoc
  module Refinements
    refine Class do
      def to_zenaton
        {
          'n' => name
        }
      end
    end
  end
end

# Load an instance of class from zenaton properties
class Class
  def self.from_zenaton(props)
    Object.const_get(props['n'])
  end
end
