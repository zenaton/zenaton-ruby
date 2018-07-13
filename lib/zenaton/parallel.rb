# frozen_string_literal: true

require 'zenaton/engine'

module Zenaton
  # Convenience class to execute jobs in parallel
  class Parallel
    # Build a collection of jobs to be executed in parallel
    # @param items [Zenaton::Interfaces::Job]
    def initialize(*items)
      @items = items
    end

    # Execute synchronous jobs
    def execute
      Engine.instance.execute(@items)
    end

    # Dispatches asynchronous jobs
    def dispatch
      Engine.instance.dispatch(@items)
    end
  end
end
