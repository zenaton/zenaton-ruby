# frozen_string_literal: true

require 'ostruct'

module Zenaton
  # :nodoc
  module Refinements
    refine OpenStruct do
      def to_zenaton
        {
          't' => table
        }
      end
    end
  end
end

# Reimplements `json/add/ostruct`
class OpenStruct
  def self.from_zenaton(props)
    new(props['t'] || props[:t])
  end
end
