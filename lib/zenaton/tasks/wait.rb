# frozen_string_literal: true

require 'zenaton/exceptions'
require 'zenaton/interfaces/task'
require 'zenaton/interfaces/event'

module Zenaton
  module Tasks
    # Class for creating waiting tasks
    class Wait < Interfaces::Task
      attr_reader :event

      # Creates a new wait task and validates the event given
      # @param event [Zenaton::Interfaces::Event]
      def initialize(event = nil)
        raise ExternalError, error unless event && (event.is_a?(String) || event.is_a?(Interfaces::Event))
        @event = event
      end

      # NOOP: No waiting when executing locally
      def handle; end

      private

      def error
        # rubocop:disable Metrics/LineLength
        "#{self.class}: Invalid parameter - argument must be a Zenaton::Interfaces::Event subclass"
        # rubocop:enable Metrics/LineLength
      end
    end
  end
end
