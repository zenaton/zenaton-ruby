# frozen_string_literal: true

require 'zenaton/interfaces/job'
require 'zenaton/traits/repeatable'

module Zenaton
  module Interfaces
    # @abstract Subclass and override {#handle} to define your custom tasks
    class Task < Job
      include Traits::Repeatable

      # Child classes should implement the handle method
      def handle
        raise NotImplemented,
              "Your workflow does not implement the `handle' method"
      end
    end
  end
end
