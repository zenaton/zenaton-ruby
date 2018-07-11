# frozen_string_literal: true

require 'zenaton/exceptions'

module Zenaton
  # Base class for jobs. Zenaton tasks and workflows inherit from this class.
  class Job
    # Child classes should implement the handle method
    def handle
      raise NotImplemented, "Your job does not implement the `handle' method"
    end
  end
end
