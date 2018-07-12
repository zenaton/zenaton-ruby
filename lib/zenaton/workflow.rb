# frozen_string_literal: true

require 'zenaton/job'

module Zenaton
  # @abstract Subclass and override {#handle} to implement a custom Workflow
  class Workflow < Job
    # Method called to run the workflow
    def handle
      raise NotImplemented,
            "Your workflow does not implement the `handle' method"
    end

    # (Optional) Implement this method if you want to use custom IDs for your
    # workflows.
    # @return [String, Integer] the custom id. Should be less than 256 bytes.
    def get_id # rubocop:disable Naming/AccessorMethodName
      nil
    end
  end
end
