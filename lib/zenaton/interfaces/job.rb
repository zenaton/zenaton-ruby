# frozen_string_literal: true

require 'zenaton/exceptions'

module Zenaton
  module Interfaces
    # @abstract Do not subclass job directly, use either Tasks or Workflows
    class Job
      # Child classes should implement the handle method
      def handle
        raise NotImplemented, "Your job does not implement the `handle' method"
      end
    end
  end
end
