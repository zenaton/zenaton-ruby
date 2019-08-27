# frozen_string_literal: true

module Zenaton
  module Contexts
    # Represents the current runtime context of a Workflow.
    class Workflow
      # @return [String] The UUID identifying the current workflow
      attr_reader :id

      # @return [Zenaton::Contexts::Workflow] a new execution context for a
      #   workflow
      def initialize(**kwargs)
        @id = kwargs[:id]
      end
    end
  end
end
