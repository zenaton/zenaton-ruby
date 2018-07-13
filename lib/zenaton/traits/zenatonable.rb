# frozen_string_literal: true

require 'zenaton/engine'
require 'zenaton/query/builder'

module Zenaton
  # Reusable modules from the Zenaton library
  module Traits
    # Module to be included in tasks and workflows
    module Zenatonable
      # Sends self as the single job to be executed to the engine and returns
      # the result
      def execute
        Engine.instance.execute([self])[0]
      end

      # Sends self as the single job to be dispatched to the engine and returns
      # the result
      def dispatch
        Engine.instance.dispatch([self])[0]
      end

      def where_id(id)
        Query::Builder.new(self.class).where_id(id)
      end
    end
  end
end
