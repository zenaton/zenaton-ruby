# frozen_string_literal: true

require 'zenaton/interfaces/job'

module Zenaton
  module Interfaces
    # @abstrat Subclass and override {#handle} to define your custom tasks
    class Task < Job
      # Child classes should implement the handle method
      def handle
        raise NotImplemented,
              "Your workflow does not implement the `handle' method"
      end
    end
  end
end
