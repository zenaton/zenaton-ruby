# frozen_string_literal: true

require 'date'

module Zenaton
  # :nodoc
  module Refinements
    refine Date do
      def to_zenaton
        {
          'y' => year,
          'm' => month,
          'd' => day,
          'sg' => start
        }
      end
    end
  end
end

# Reimplements `json/add/date`
class Date
  def self.from_zenaton(props)
    civil(*props.values_at('y', 'm', 'd', 'sg'))
  end
end
