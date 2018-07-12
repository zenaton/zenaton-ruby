# frozen_string_literal: true

require 'zenaton/exceptions'
require 'zenaton/workflow'
require 'zenaton/traits/zenatonable'

module Zenaton
  module Workflows
    # @abstract Subclass and override {#versions} to create your own versionned
    # workflows
    class Version < Zenaton::Workflow
      include Zenaton::Traits::Zenatonable

      # @return [Array<Class>] an array containing the class name for each
      # version, ordered from the oldest to the most recent version
      def versions
        raise NotImplemented,
              "Please override the `versions' method in your subclass"
      end

      def initialize(*args)
        @args = args
      end

      def handle
        current_implementation.handle
      end

      def current
        _get_versions[-1]
      end

      def initial
        _get_versions[0]
      end

      def current_implementation
        current.new(*@args)
      end

      protected

      def _get_versions
        raise ExternalError unless versions.is_a? Array
        raise ExternalError unless versions.any?
        versions.each do |version|
          raise ExternalError unless version < Zenaton::Workflow
        end
        versions
      end
    end
  end
end
