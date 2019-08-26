# frozen_string_literal: true

require 'zenaton/interfaces/job'
require 'zenaton/contexts/task'

module Zenaton
  module Interfaces
    # @abstract Subclass and override {#handle} to define your custom tasks
    class Task < Job
      # Child classes should implement the handle method
      def handle
        raise NotImplemented,
              "Your workflow does not implement the `#handle' method"
      end

      # (Optional) Implement this method for automatic retrial of task in
      # case of failures.
      # @param _exception [Exception] the reason for the task failure.
      # @return [#negative?, FalseClass, NilClass] the non-negative amount of
      #   seconds to wait before automatically retrying this task. Falsy values
      #   will avoid retrial. Other values will cause the retrial to fail.
      def on_error_retry_delay(_exception)
        nil
      end

      # @return [Zenaton::Contexts::Task] the task execution context
      def context
        @context || Contexts::Task.new
      end

      # @private
      # Sets a new context if none has been set yet.
      # This is called from the zenaton agent and will raise if called twice.
      # @raise [ArgumentError] when the context was already set.
      def add_context(**attributes)
        message = <<~ERROR
          Context has already been set and cannot be mutated.
        ERROR
        raise ArgumentError, message if @context

        @context = Contexts::Task.new(attributes)
      end
    end
  end
end
