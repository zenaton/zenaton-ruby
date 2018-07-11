# frozen_string_literal: true

require 'singleton'

module Zenaton
  # Zenaton Client
  class Client
    include Singleton

    # Start the specified workflow
    # @param workflow [Zenaton::Workflow]
    def start_workflow(workflow); end
  end
end
