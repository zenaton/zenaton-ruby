# frozen_string_literal: true

require 'zenaton/job'

module Zenaton
  # Base class for Workflows. Your workflows should inherit from this class
  class Workflow < Job
    # Child classes should implement the handle method
    def handle
      raise NotImplemented,
            "Your workflow does not implement the `handle' method"
    end
  end
end
