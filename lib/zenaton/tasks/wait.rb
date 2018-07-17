# frozen_string_literal: true

require 'zenaton/exceptions'
require 'zenaton/interfaces/task'
require 'zenaton/interfaces/event'
require 'zenaton/traits/with_timestamp'
require 'zenaton/traits/zenatonable'

module Zenaton
  # Subclasses of Zenaton::Interfaces::Task
  module Tasks
    # Class for creating waiting tasks
    class Wait < Interfaces::Task
      attr_reader :event

      include Traits::WithTimestamp
      include Traits::Zenatonable

      # Creates a new wait task and validates the event given
      # @param event [Zenaton::Interfaces::Event]
      def initialize(event = nil)
        raise ExternalError, error unless valid_param(event)
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

      def valid_param(event)
        event.nil? || event.is_a?(String) || event_class?(event)
      end

      def event_class?(event)
        event.class == Class && event < Zenaton::Interfaces::Event
      end
    end
  end
end
