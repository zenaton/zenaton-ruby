# frozen_string_literal: true

require 'zenaton/exceptions'
require 'zenaton/interfaces/workflow'
require 'zenaton/traits/zenatonable'

module Zenaton
  # Module for the workflow manager and the versioned workflows
  module Workflows
    # @abstract Subclass and override {#versions} to create your own versionned
    # workflows
    class Version < Interfaces::Workflow
      include Traits::Zenatonable

      # @return [Array<Class>] an array containing the class name for each
      # version, ordered from the oldest to the most recent version
      def versions
        raise NotImplemented,
              "Please override the `versions' method in your subclass"
      end

      def initialize(*args)
        @args = args
      end

      # Calls handle on the current implementation
      def handle
        current_implementation.handle
      end

      # Get the current implementation class
      # @return [Class]
      def current
        _get_versions[-1]
      end

      # Get the first implementation class
      # @return [Class]
      def initial
        _get_versions[0]
      end

      # Returns an instance of the current implementation
      # @return [Zenaton::Interfaces::Workflow]
      def current_implementation
        current.new(*@args)
      end

      protected

      def _get_versions
        raise ExternalError unless versions.is_a? Array
        raise ExternalError unless versions.any?
        versions.each do |version|
          raise ExternalError unless version < Interfaces::Workflow
        end
        versions
      end
    end
  end
end
