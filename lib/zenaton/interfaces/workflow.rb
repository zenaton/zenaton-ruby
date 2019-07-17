# frozen_string_literal: true

require 'zenaton/interfaces/job'
require 'zenaton/traits/repeatable'

module Zenaton
  module Interfaces
    # @abstract Subclass and override {#handle} to implement a custom Workflow
    class Workflow < Job
      include Traits::Repeatable

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
    end
  end
end
