# frozen_string_literal: true

require 'active_support/concern'
require 'zenaton/engine'
require 'zenaton/query/builder'

module Zenaton
  # Reusable modules from the Zenaton library
  module Traits
    # Module to be included in tasks and workflows
    module Zenatonable
      extend ActiveSupport::Concern
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

      class_methods do
        # Search for workflows to interact with.
        # For available methods, see {Zenaton::Query::Builder}
        # @param id [String] (Optional) ID for a given worflow
        # @return [Zenaton::Query::Builder] a query builder object
        def where_id(id)
          Query::Builder.new(self.class).where_id(id)
        end
      end
    end
  end
end
