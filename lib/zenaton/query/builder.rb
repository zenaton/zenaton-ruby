# frozen_string_literal: true

require 'zenaton/exceptions'
require 'zenaton/client'
require 'zenaton/interfaces/workflow'

module Zenaton
  # Wrapper module for interacting with jobs
  module Query
    # Wrapper class around the client to interact with workflows by id
    class Builder
      def initialize(klass)
        check_klass(klass)
        @klass = klass
        @client = Client.instance
      end

      # Sets the id of the workflow we want to find
      # @param id [String, NilClass] the id
      # @return [Zenaton::Query::Builder] the current builder
      def where_id(id)
        @id = id
        self
      end

      # Finds a workflow
      # @return [Zenaton::Interfaces::Workflow]
      def find
        @client.find_workflow(@klass.to_s, @id)
      end

      # Sends an event to a workflow
      # @param event [Zenaton::Interfaces::Event] the event to send
      # @return [Zenaton::Query::Builder] the current builder
      def send_event(event)
        @client.send_event(@klass.to_s, @id, event)
        self
      end

      # Stops a workflow
      # @return [Zenaton::Query::Builder] the current builder
      def kill
        @client.kill_workflow(@klass.to_s, @id)
        self
      end

      # Pauses a workflow
      # @return [Zenaton::Query::Builder] the current builder
      def pause
        @client.pause_workflow(@klass.to_s, @id)
        self
      end

      # Resumes a workflow
      # @return [Zenaton::Query::Builder] the current builder
      def resume
        @client.resume_workflow(@klass.to_s, @id)
        self
      end

      private

      def check_klass(klass)
        msg = "#{klass} should be a subclass of Zenaton::Interfaces::Workflow"
        raise ExternalError, msg unless klass < Interfaces::Workflow
      end
    end
  end
end
