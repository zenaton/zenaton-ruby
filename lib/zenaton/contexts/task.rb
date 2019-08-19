# frozen_string_literal: true

module Zenaton
  module Contexts
    # Represents the current runtime context of a Task.
    #
    # The information provided by the context can be useful to alter the
    # behaviour of the task.
    #
    # For example, you can use the attempt index to know if a task has been
    # automatically retried or not and how many times, and decide to do
    # something when you did not expect the task to be retried more than X
    # times.
    #
    # You can also use the attempt number in the `on_error_retry_delay` method
    # of a task in order to implement complex retry strategies.
    class Task
      # @return [String] The UUID identifying the current task
      attr_reader :id

      # @return [Integer] The number of times this task has been automatically
      #   retried. This counter is reset if you issue a manual retry from your
      #   dashboard
      attr_reader :retry_index

      # @return [Zenaton::Contexts::Task] a new execution context for a task
      def initialize(**kwargs)
        @id = kwargs[:id]
        @retry_index = kwargs[:retry_index]
      end
    end
  end
end
