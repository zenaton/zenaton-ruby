# frozen_string_literal: true

require 'zenaton/job'

module Zenaton
  # Base class for Tasks. Your tasks should inherit from this class
  class Task < Job
    # Child classes should implement the handle method
    def handle
      raise NotImplemented,
            "Your workflow does not implement the `handle' method"
    end
  end
end
