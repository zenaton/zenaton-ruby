# frozen_string_literal: true

require 'zenaton/interfaces/job'
require 'zenaton/contexts/workflow'

module Zenaton
  module Interfaces
    # @abstract Subclass and override {#handle} to implement a custom Workflow
    class Workflow < Job
      # Method called to run the workflow
      def handle
        raise NotImplemented,
              "Your workflow does not implement the `handle' method"
      end

      # (Optional) Implement this method if you want to use custom IDs for your
      # workflows.
      # @return [String, Integer, NilClass] the custom id. Must be <= 256 bytes.
      def id
        nil
      end

      # @return [Zenaton::Contexts::Workflow] the workflow execution context
      def context
        @context || Contexts::Workflow.new
      end

      # @private
      # Sets a new context if none has been set yet.
      # This is called from the zenaton agent and will raise if called twice.
      # @raise [ArgumentError] when the context was already set.
      def add_context(**attributes)
        raise ArgumentError if @context
        @context = Contexts::Workflow.new(attributes)
      end
    end
  end
end
